
" Instructions
"
" Windows - Download vim https://www.vim.org/download.php
"           Rename the vim* version folder to vim
"           vim's root is in the new vim/ folder
"
" Mac/Linux - mkdir ~/.vim
"             vim's root is in ~/.
"
" Make sure ssh keys for git and gitlab are setup
"
" Copy the contents of this repo into vim's root, only windows needs the binaries
" ./vim
" call Install()
" Restart vim

let s:vim_root     = expand($HOME .. '/.vim')
let s:plugins_path = s:vim_root .. '/pack/plugin/start'

if (has('win64'))
  let s:vim_root     = expand($VIM)
  let s:plugins_path = expand($VIM . '/' . "pack/plugin/start")
endif

let s:vimrc_path = s:vim_root .. '/vim-rc'

let s:vim_rc = [
      \ "git@gitlab.com:Aborres/Vim-rc.git",
      \]

let s:personal_plugins = [
      \ "https://github.com/Aborres/vim-bates",
      \ "https://github.com/Aborres/vim-blackboard",
      \ "https://github.com/Aborres/vim-cheater",
      \ "https://github.com/Aborres/vim-everything",
      \ "https://github.com/Aborres/vim-jobs",
      \ "https://github.com/Aborres/vim-p4",
      \]

let s:external_plugins = [
      \ "https://github.com/prabirshrestha/async.vim",
      \ "https://github.com/prabirshrestha/asyncomplete.vim",
      \ "https://github.com/prabirshrestha/asyncomplete-lsp.vim",
      \ "https://github.com/skywind3000/asyncrun.vim",
      \ "https://github.com/rafi/awesome-vim-colorschemes",
      \ "https://github.com/itchyny/lightline.vim",
      \ "https://github.com/prabirshrestha/vim-lsp",
      \ "https://github.com/sheerun/vim-polyglot",
      \ "https://github.com/mhinz/vim-startify",
      \]

func! s:OpenTerminal() abort

  for buf in range(1, bufnr('$'))
    if bufexists(buf) && getbufvar(buf, '&buftype') == 'terminal'
      return 1
    endif
  endfor

  execute "terminal ++curwin"
  return 0

endfunc

func! s:Execute(cmd) abort
  call term_sendkeys(bufnr('!'), a:cmd .. "\<CR>")
endfunc

func! s:InstallPack(path, pack, to='') abort
  for l:plugin in a:pack
    let l:cmd = printf('git -C %s clone %s %s', shellescape(expand(a:path)), shellescape(l:plugin), a:to)
    call s:Execute(l:cmd)
  endfor
endfunc

func! Install() abort

  call s:OpenTerminal()

  if !isdirectory(s:plugins_path)
    call mkdir(s:plugins_path, "p")
  endif

  "call s:InstallPack(s:vim_root, s:vim_rc, s:vimrc_path)

  "call s:InstallPack(s:plugins_path, s:personal_plugins)
  call s:InstallPack(s:plugins_path, s:external_plugins)

endfunc

func! s:UpdateRepo(path) abort
 if (isdirectory(a:path) && isdirectory(a:path) . '/.git')
   let l:cmd = 'git -C ' . shellescape(a:path) . ' pull'
   call s:Execute(l:cmd)
 endif
endfunc

func! s:UpdatePack(pack) abort

  let l:plugins = globpath(a:pack, '*', 0, 1)

  for l:item in l:plugins
    call s:UpdateRepo(l:item)
  endfor

endfunc

func! UpdatePlugins() abort

  call s:OpenTerminal()

  call s:UpdateRepo(s:vimrc_path)
  call s:UpdatePack(s:plugins_path)

endfunc

if isdirectory(s:vimrc_path)
  execute 'source ' .. s:vimrc_path .. '/_vimrc'
else
  colorscheme zaibatsu
  set number
endif
