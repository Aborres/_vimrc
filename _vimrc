let s:path = fnameescape(expand($HOME))

if (has('win64'))
	let s:path = fnameescape(expand($VIM))
endif

execute 'source ' .. s:path .. '/.vim/.vimrc'
