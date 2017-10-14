# gh-issue-backupper

Download issue and pull request log files as JSON

___

## Usage
Before use, you have to prepare `my_token.txt` and `repository_list.txt`.  
`my_token.txt` is where you write your OAuth token. OAuth is needed to access private repository.  
And you also have to write repository names you want to get log in `repository_list.txt`. For example:  
```
yammmt/sandbox
yammmt/Sphero-Auto-Pilot
```

After preparing above two files, open terminal and type followings:  
```bash
$ bundle install
$ ruby gh_issue_backupper.rb
```
