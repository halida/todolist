site:
	middleman build
	cp build/* ~/Dropbox/Apps/site44/todolist.site44.com  -r

clean:
	find |grep ~$ |xargs rm -f