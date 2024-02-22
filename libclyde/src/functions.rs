use which::which_global;
use toml;
use std::fs;
use std::collections::HashMap;
use crate::{Alias, Command};

pub fn is_executable(name: &str) -> bool {
    let binary = name.split_whitespace().next().unwrap_or("");
    which_global(binary).is_ok()
}

pub fn open_file(path: &str) -> String {
    fs::read_to_string(path).unwrap()
}

pub fn process_editor(editor: Vec<String>, mut zsh: String) -> String {
    for e in editor {
        if is_executable(&e) {
            zsh.push_str(&format!("export EDITOR={}\n", e));
            break;
        }
    }
    zsh
}

pub fn process_simple(simple: Option<toml::Value>, mut zsh: String) -> String {
    if let Some(simple) = simple {
        let simple = simple.as_table().unwrap();
        for (k, v) in simple {
            if let Some(v_str) = v.as_str() {
                if is_executable(v_str) || v_str.starts_with("$") {
                    zsh.push_str(&format!("alias {}='{}'\n", k, v_str));
                }
            }
        }
    }
    zsh
}

pub fn process_addflags(addflags: Option<toml::Value>, mut zsh: String) -> String {
    if let Some(addflags) = addflags {
        let addflags = addflags.as_table().unwrap();
        for (k, v) in addflags {
            if let Some(v_str) = v.as_str() {
                if is_executable(k) {
                    zsh.push_str(&format!("alias {}='{} {}'\n", k, k, v_str));
                }
            }
        }
    }
    zsh
}

pub fn process_alias(alias: Option<HashMap<String, Alias>>, mut zsh: String) -> String {
    if let Some(alias) = alias {
        for (_, v) in alias {
            match &v.command {
                Command::Single(cmd) => {
                    if is_executable(&cmd) {
                        match &v.aliases {
                            Command::Single(alias) => {
                                zsh.push_str(&format!("alias {}='{}'\n", alias, cmd));
                            }
                            Command::Multiple(aliases) => {
                                for alias in aliases {
                                    zsh.push_str(&format!("alias {}='{}'\n", alias, cmd));
                                }
                            }
                        }
                    }
                }
                Command::Multiple(cmds) => {
                    for cmd in cmds {
                        if is_executable(&cmd) {
                            match &v.aliases {
                                Command::Single(alias) => {
                                    zsh.push_str(&format!("alias {}='{}'\n", alias, cmd));
                                }
                                Command::Multiple(aliases) => {
                                    for alias in aliases {
                                        zsh.push_str(&format!("alias {}='{}'\n", alias, cmd));
                                    }
                                }
                            }
                            break;
                        }
                    }
                }
            }
        }
    }
    zsh
}

pub fn process_path(path: Vec<String>, mut zsh: String) -> String {
    let joined_path = path.join(":");
    zsh.push_str(&format!("export PATH=\"{}:$PATH\"\n", joined_path));
    zsh
}

pub fn prefix_string(prefix: &str, s: String, mut zsh: String) -> String {
    for line in s.lines() {
        zsh.push_str(&format!("{}{}\n", prefix, line));
    }
    zsh
}