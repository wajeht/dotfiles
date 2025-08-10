#!/bin/bash

source "$(dirname "$0")/common.sh"

install_kanata() {
    step "⌨️  Installing Kanata Configuration"
    
    info "Installing Kanata configuration..."
    mkdir -p ~/.config/kanata
    cp -r .config/kanata/* ~/.config/kanata/
    task "Copied configuration to ~/.config/kanata/"
    
    info "Creating launch agent for Kanata..."
    local plist_file="$HOME/Library/LaunchAgents/com.kanata.daemon.plist"
    
    cat > "$plist_file" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.kanata.daemon</string>
    <key>ProgramArguments</key>
    <array>
        <string>/opt/homebrew/bin/kanata</string>
        <string>-c</string>
        <string>$HOME/.config/kanata/config.kbd</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
    <key>StandardErrorPath</key>
    <string>/tmp/kanata.err</string>
    <key>StandardOutPath</key>
    <string>/tmp/kanata.out</string>
</dict>
</plist>
EOF
    task "Created launch agent"
    
    info "Loading Kanata daemon..."
    launchctl unload "$plist_file" 2>/dev/null
    launchctl load "$plist_file"
    task "Loaded Kanata daemon"
    
    success "Kanata configuration installed"
    warning "Grant Input Monitoring permissions to Kanata:"
    info "System Settings → Privacy & Security → Privacy → Input Monitoring"
}

uninstall_kanata() {
    step "🗑️  Removing Kanata Configuration"
    
    echo "📋 This will remove:"
    echo "   • ~/.config/kanata/ directory"
    echo "   • Kanata launch agent"
    echo "   • Stop running Kanata daemon"
    echo ""
    read -p "❓ Continue with Kanata uninstall? [y/N] " confirm && [ "$confirm" = "y" ] || exit 1
    
    info "Stopping Kanata daemon..."
    local plist_file="$HOME/Library/LaunchAgents/com.kanata.daemon.plist"
    if [ -f "$plist_file" ]; then
        launchctl unload "$plist_file" 2>/dev/null
        rm "$plist_file"
        task "Stopped and removed launch agent"
    fi
    
    info "Removing Kanata configuration..."
    rm -rf ~/.config/kanata
    task "Removed ~/.config/kanata/"
    
    success "Kanata configuration removed successfully!"
    info "💡 To reinstall: make kanata install"
}

main() {
    case "${1:-install}" in
    install)
        install_kanata
        ;;
    uninstall)
        uninstall_kanata
        ;;
    *)
        install_kanata
        ;;
    esac
}

main "$@"