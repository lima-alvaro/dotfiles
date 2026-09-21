autoload -Uz bashcompinit
bashcompinit
complete -o nospace -C 'mc "${words[0]}" "${words[CURRENT-1]}" "${words[CURRENT-2]}"' mc
