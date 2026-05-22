# add to ~/.config/fish/conf.d/drift.fish
if status is-interactive
    set -x DRIFT_TIMEOUT 120
    drift shell-init fish | source
end
