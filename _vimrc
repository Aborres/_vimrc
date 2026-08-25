"-----------------------------------------------------------------------------
" Instructions
"
" Clone with git clone git@github.com:Aborres/_vimrc.git .
"
" Windows - Download vim https://www.vim.org/download.php
"         - Copy Contents inside of vim/vim**/ 
"
" Mac/Linux - Copy Contents inside of ~
"
" Make sure ssh keys for git and gitlab are setup
"
" call Install()
" Restart vim
"-----------------------------------------------------------------------------

"-----------------------------------------------------------------------------
" Config
"-----------------------------------------------------------------------------

const s:vim_root = has('win64') ? expand($VIM) : expand($HOME)

const s:plugins_root = s:vim_root .. '/pack/plugin'

const s:plugins_path          = s:plugins_root .. '/start'
const s:optional_plugins_path = s:plugins_root .. '/opt'

const s:vimrc_path = s:vim_root .. '/.vim'

const s:vim_rc = [
      \ "git@gitlab.com:Aborres/Vim-rc.git",
      \]

const s:personal_plugins = [
      \ "https://github.com/Aborres/vim-bates",
      \ "https://github.com/Aborres/vim-blackboard",
      \ "https://github.com/Aborres/vim-everything",
      \ "https://github.com/Aborres/vim-jobs",
      \ "git@github.com:Aborres/vim-cheater.git",
      \ "git@github.com:Aborres/vim-p4.git",
      \]

const s:external_plugins = [
      \ "https://github.com/rafi/awesome-vim-colorschemes",
      \ "https://github.com/itchyny/lightline.vim",
      \ "https://github.com/sheerun/vim-polyglot",
      \ "https://github.com/mhinz/vim-startify",
      \]

const s:vim8_lsp = [
      \ "https://github.com/prabirshrestha/async.vim",
      \ "https://github.com/prabirshrestha/asyncomplete.vim",
      \ "https://github.com/prabirshrestha/asyncomplete-lsp.vim",
      \ "https://github.com/prabirshrestha/vim-lsp",
      \]

const s:vim9_lsp = [
      \ "https://github.com/yegappan/lsp",
      \]

"-----------------------------------------------------------------------------
" Install
"-----------------------------------------------------------------------------

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

  if (a:to != '' && isdirectory(a:to))
    echo(printf("Can't install, destination directory: %s is not empty", a:to))
    return 0
  endif

  call s:OpenTerminal()
  for l:plugin in a:pack
    let l:cmd = printf('git -C %s clone %s %s', shellescape(expand(a:path)), shellescape(l:plugin), a:to)
    call s:Execute(l:cmd)
  endfor

  return 1
endfunc

func! Vimrc_InstallVimRC() abort
  call s:InstallPack(s:vim_root, s:vim_rc, s:vimrc_path)
endfunc

func! s:CheckCreate(path) abort
  if !isdirectory(a:path)
    call mkdir(a:path, "p")
  endif
endfunc

func! s:InstallPluginPack(path, list) abort
  call s:CheckCreate(a:path)
  call s:InstallPack(a:path, a:list)
endfunc

func! Vimrc_InstallIntPlugins(path) abort
  call s:InstallPluginPack(a:path, s:personal_plugins)
endfunc

func! Vimrc_InstallExtPlugins(path) abort
  call s:InstallPluginPack(a:path, s:external_plugins)
endfunc

func! Vimrc_InstallLSP(path) abort
  if (has('vim9script'))
    call s:InstallPluginPack(a:path, s:vim9_lsp)
  else
    call s:InstallPluginPack(a:path, s:vim8_lsp)
  endif
endfunc

func! Vimrc_Install() abort
  call Vimrc_InstallVimRC()
  call Vimrc_InstallIntPlugins(s:plugins_path)
  call Vimrc_InstallExtPlugins(s:plugins_path)
  call Vimrc_InstallLSP(s:optional_plugins_path)
endfunc

"-----------------------------------------------------------------------------
" Update 
"-----------------------------------------------------------------------------

func! s:UpdateRepo(path) abort
 if (isdirectory(a:path) && isdirectory(a:path) .. '/.git')
   let l:cmd = 'git -C ' .. shellescape(a:path) .. ' pull'
   call s:Execute(l:cmd)
 endif
endfunc

func! s:UpdatePack(pack) abort

  let l:plugins = globpath(a:pack, '*', 0, 1)

  for l:item in l:plugins
    call s:UpdateRepo(l:item)
  endfor

endfunc

func! Vimrc_UpdatePlugins() abort

  call s:OpenTerminal()

  call s:UpdateRepo(s:vimrc_path)
  call s:UpdatePack(s:plugins_path)

endfunc

"-----------------------------------------------------------------------------
" Delete
"-----------------------------------------------------------------------------

func! Vimrc_DeleteVimRC() abort
  call delete(s:vimrc_path, 'd')
endfunc

func! Vimrc_DeletePlugins() abort
  call delete(s:plugins_root, 'd')
endfunc

func! Vimrc_Delete() abort
  call Vimrc_DeleteVimRC()
  call Vimrc_DeletePlugins()
endfunc

"-----------------------------------------------------------------------------
" Init
"-----------------------------------------------------------------------------

if isdirectory(s:vimrc_path)
  execute 'source ' .. s:vimrc_path .. '/_vimrc'
else
  colorscheme zaibatsu
  set number
endif

"-----------------------------------------------------------------------------
