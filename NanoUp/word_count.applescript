on run argv
	
	set myName to item 1 of argv
	set mySecret to item 2 of argv
	
	tell application "Pages"
		
		tell body text of front document
			set wordCnt to count words
		end tell
		
	end tell
	
	set UnixPath to POSIX path of ((path to me as text) & "::")
	do shell script "python " & UnixPath & "upload.py " & myName & " " & mySecret & " " & wordCnt
	
end run

