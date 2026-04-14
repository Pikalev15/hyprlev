function gpersonal
    cd ~/Pikalev15
    git add .
    git commit -m $argv[1]
    git push
    cd
end
