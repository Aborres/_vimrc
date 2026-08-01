let g:ve_root_dir = fnamemodify(resolve(expand('<sfile>:p')), ':h') . '/../..'

"Constants
let g:ve_open_enter = 0
let g:ve_open_vs    = 1
let g:ve_open_sp    = 2
let g:ve_open_tab   = 3

let g:ve_input_mode   = 0
let g:ve_nav_mode     = 1
"--Constants

let g:ve_status = 1
let g:ve_offset_txt =  ""

let g:ve_screen_space_idx = 0
let g:ve_curr_pag         = 0

let g:ve_current_buff = []
let g:ve_current_mode = g:ve_input_mode

let g:ve_search_txt = g:ve_internal_cursor
let g:ve_py_search_txt = g:ve_internal_cursor

"UI
let g:ve_top_offset    = 2
let g:ve_bottom_offset = 4
"--UI

let s:ve_initialized = 0 
let s:ve_popup = -1
let s:ve_cache_popup = 1

let s:ve_timer = -1

let s:ve_cursor_state = 1

func! s:IsPopupValid() abort
  return s:ve_popup != -1
endfunc

func! ve#plugin#reset() abort

  "Python
  let g:ve_total_r = 0
  let g:ve_num_r   = 0

  let g:ve_r_names = []
  let g:ve_r_paths = []
  let g:ve_r_types = []

  let g:ve_current_buff = []

  let g:ve_current_mode = g:ve_input_mode

  let g:ve_screen_space_idx = 0
  let g:ve_curr_pag         = 0

  let g:ve_search_txt = g:ve_internal_cursor
  let g:ve_py_search_txt = g:ve_internal_cursor

  call ve#plugin#init()

  let s:ve_timer = -1

endfunc

func! ve#plugin#init() abort
  if (s:ve_initialized == 0)

    let l:wrapper_file = escape(g:ve_root_dir, ' ') . '/python/wrapper.py'

    if (g:ve_use_python3 == 1)
      exe 'py3file ' . l:wrapper_file
    else
      exe 'pyfile ' . l:wrapper_file
    endif

    let s:ve_initialized = 1
  endif
endfunc

func! ve#plugin#destroy() abort

  call ve#plugin#reset()

  if (s:IsPopupValid())
    call popup_close(s:ve_popup)
    let s:ve_popup = -1
  endif
endfunc

func! ve#plugin#search_w(text, from) abort

  let g:ve_search_txt = a:text

  let g:ve_last_search   = ve#cursor#remove_cursor(g:ve_search_txt)
  let g:ve_py_search_txt = g:ve_last_search

  let g:ve_offset_txt = a:from 
  let g:ve_status = 1

  if (g:ve_use_python3 == 1)
    python3 VE_SearchWrapper()
  else
    python VE_SearchWrapper()
  endif

  return g:ve_status
endfunc

func ve#plugin#ve(keep_prev_search = 1) abort

  if ((a:keep_prev_search != 1) || (g:ve_keep_prev_search != 1))
    let g:ve_search_txt = ""
  endif

  call ve#plugin#search(g:ve_search_txt)

endfunc

func! s:Blink(timer) abort
  let s:ve_cursor_state = !s:ve_cursor_state
  call ve#update#screen_body(s:ve_popup, s:ve_cursor_state)
endfunc

func! s:IsBlinkEnabled() abort
  return g:ve_style.cursor.blink > 0
endfunc

func! ve#plugin#search(txt) abort

  " If we are searching with a path insert the cursor at the front to start writing there
  " Otherwise it might be an already formed query
  let l:search_text = a:txt
  if (len(l:search_text))
    if ((l:search_text[0] == "\\") || (l:search_text[0] == "/"))
      let l:search_text = ve#cursor#move_front(l:search_text, 1)
    endif
  endif

  let l:same_search = g:ve_last_search == ve#cursor#remove_cursor(l:search_text)
  let l:valid_popup = s:IsPopupValid()
  let l:cache = l:valid_popup && g:ve_cache_search && l:same_search
  if (!l:cache)
    call ve#plugin#reset()
    if (!ve#plugin#search_w(l:search_text, 0))
      return 0
    endif
  endif

  if (l:valid_popup)
    call popup_show(s:ve_popup)
  else
    let l:ve_args = #{
        \ title: 'vim-Everything',
        \ filter: 've#filter#call',
        \ callback: 've#callback#call',
        \ close: 'click',
      \}
    let s:ve_popup = popup_menu('', l:ve_args)
  endif

  let l:text = ve#update#screen_text(g:ve_search_txt, 0)
  call popup_settext(s:ve_popup, l:text)

  call ve#plugin#refresh_style()

  if (s:IsBlinkEnabled())
    let s:ve_cursor_state = 1
    let s:ve_timer = timer_start(g:ve_style.cursor.blink, function('s:Blink'), {'repeat': -1}) 
  endif
endfunc

func! ve#plugin#close(id) abort

  if (s:ve_cache_popup)
    call popup_hide(a:id)
  else
    call popup_close(a:id, [-1, -1])
  endif

  if (s:IsBlinkEnabled() && (s:ve_timer > -1))
    call timer_stop(s:ve_timer)
    let s:ve_timer = -1
  endif
  return 1
endfunc

func! s:PopupStyle(args) abort

  let l:args = a:args

  let l:args.resize             = g:ve_style.resize
  let l:args.wrap               = g:ve_style.wrap
  let l:args.scrollbar          = g:ve_style.scrollbar
  let l:args.borderchars        = g:ve_style.border
  let l:args.opacity            = g:ve_style.opacity
  let l:args.highlight          = g:ve_style.notification
  let l:args.borderhighlight    = g:ve_style.border_style
  let l:args.scrollbarhighlight = g:ve_style.scrollbar_style
  let l:args.thumbhighlight     = g:ve_style.thumb

  if (g:ve_style.window_w)
    let l:args.minwidth = g:ve_style.window_w
    let l:args.maxwidth = g:ve_style.window_w
  endif

  return l:args

endfunc

func! ve#plugin#refresh_style() abort
  if (s:IsPopupValid())
    let l:ve_args = s:PopupStyle({})
    call popup_setoptions(s:ve_popup, l:ve_args)
  endif
endfunc

func! s:VEQueryFromPrevSearch(path) abort

  if (g:ve_keep_prev_search)
    let l:file_name = ve#filter#clear_path_text(g:ve_last_search)
    if (l:file_name != g:ve_last_search)
      return ve#cursor#move_after(l:file_name, a:path)
    endif
  endif

  return a:path
endfunc

func! s:VECleanPathForSearch(path) abort

  let l:txt = ve#plugin#check_sep_terminated(a:path)
  let l:pos = ve#filter#split_name_path(l:txt)

  if (l:pos > 0)
    let l:txt = l:txt[l:pos:]
  endif

  return l:txt
endfunc

func! ve#plugin#search_in_path(path) abort

  let l:txt = s:VECleanPathForSearch(a:path)
  let l:txt = s:VEQueryFromPrevSearch(l:txt)

  call ve#plugin#search(l:txt)

endfunc

func! ve#plugin#search_text_in_path(file, path) abort

  if (a:file == '')
    call ve#plugin#search_in_path(a:path)
    return
  endif

  let l:txt = s:VECleanPathForSearch(a:path)
  let l:txt = ve#cursor#move_after(a:file, l:txt)

  call ve#plugin#search(l:txt)

endfunc

func! ve#plugin#refresh(id = 0) abort

  if (!ve#plugin#search_w(g:ve_search_txt, 0))
    return 0
  endif

  let l:id = a:id
  if (l:id <= 0)
    let l:id = s:ve_popup
  endif

  if (l:id <= 0)
    return 0
  endif

  call popup_settext(l:id, ve#update#screen_text(g:ve_search_txt, 0))
  return 1

endfunc

func! ve#plugin#check_sep_terminated(path) abort

  let l:len = len(a:path)
  if (l:len > 0)
    let l:end = a:path[l:len - 1]
    let l:term = l:end == '/' || l:end == '\'
    if (!l:term)
      return a:path . '\'
    endif
  endif

  return a:path
endfunc
