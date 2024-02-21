use serde_derive::Deserialize;
use std::collections::{HashMap};
mod functions;

#[derive(Deserialize)]
#[serde(untagged)]
enum Command {
    Single(String),
    Multiple(Vec<String>),
}

#[derive(Deserialize)]
struct Config {
    settings: Option<Settings>,
    simple: Option<toml::Value>,
    addflags: Option<toml::Value>,
    alias: Option<HashMap<String, Alias>>,
}

#[derive(Deserialize)]
struct Settings {
    plugins: Vec<String>,
    setopts: String,
    zstyle: String,
    env: String,
    path: Vec<String>,
}

#[derive(Deserialize)]
struct Alias {
    command: Command,
    aliases: Command,
}

fn main() {
    let args: Vec<String> = std::env::args().collect();
    let config = functions::open_file(&args[1]);
    let config: Config = toml::from_str(&config).unwrap();

    let mut zsh = String::new();

    if let Some(settings) = config.settings {
        zsh = functions::prefix_string("export ", settings.env, zsh);
        zsh = functions::process_path(settings.path, zsh);
        zsh = functions::prefix_string("setopt ", settings.setopts, zsh);
        zsh = functions::prefix_string("zstyle ", settings.zstyle, zsh);
    } else {
        println!("No settings found");
    }
    
    zsh = functions::process_simple(config.simple, zsh);
    zsh = functions::process_addflags(config.addflags, zsh);
    zsh = functions::process_alias(config.alias, zsh);
    
    println!("{}", zsh);
}

