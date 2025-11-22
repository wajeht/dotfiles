# Alfred Terminal Integration with Ghostty

## Configuration Location
Alfred Preferences → Features → Terminal → Application: Custom

## AppleScript Code
```applescript
on alfred_script(q)
    do shell script "/Applications/Ghostty.app/Contents/MacOS/ghostty -e /bin/zsh -c " & quoted form of (q & "; exec zsh")
end alfred_script
```

## How It Works
- `on alfred_script(q)` - Alfred passes the command as parameter `q`
- `-e /bin/zsh -c` - Tells Ghostty to execute a command via zsh
- `q & "; exec zsh"` - Appends `exec zsh` to keep the shell open after command execution
- `quoted form of` - Properly escapes the command string for shell execution

## Usage
Type `> your-command` in Alfred to execute commands in Ghostty terminal.
