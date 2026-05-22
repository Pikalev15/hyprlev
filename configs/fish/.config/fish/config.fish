if status is-interactive
    # Commands to run in interactive sessions can go here
    set -g fish_greeting

    # Only run neofetch if it exists and we want it (it's slow)
    neofetch 

    # Paths (moved inside interactive block or simplified)
    fish_add_path ~/go/bin
    fish_add_path ~/.cargo/bin
    fish_add_path /home/lev15/.spicetify
    
    # Add local bin if not already in path
    if not contains /home/lev15/.local/bin $PATH
        set -gx PATH $PATH /home/lev15/.local/bin
    end
end
