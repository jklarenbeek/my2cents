\\dfs4\snapshot\snapshot64.exe C: \\dfs4\snapshot\$computername-$disk-$week-$weekday.sna -h\\dfs4\snapshot\$computername-$disk-$week.hsh --exclude:\Temp,\Windows\Memory.dmp,\Windows\Minidump\* -L300000 -W -PW=<somepassword>
\\dfs4\snapshot\snapshot64.exe D: \\dfs4\snapshot\$computername-$disk-$week-$weekday.sna -h\\dfs4\snapshot\$computername-$disk-$week.hsh -L300000 -W -PW=<somepassword>
