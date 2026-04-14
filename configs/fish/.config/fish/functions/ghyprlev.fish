function ghyprlev
    cd ~/hyprlev
    git add .
    git commit -m $argv[1]
    git push
    cd
end
