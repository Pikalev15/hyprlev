function g
    if test (count $argv) -eq 2
        cd ~/$argv[1]
    end
    git add .
    git commit -m $argv[-1]
    git push
    cd
end
