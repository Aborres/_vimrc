
func! s:TestRemoveCursor(input) abort
  return ve#cursor#remove_cursor(a:input)
endfunc

func! s:TestMoveCursorFront(input) abort
  return ve#cursor#move_front(a:input)
endfunc

func! s:TestMoveCursorBack(input) abort
  return ve#cursor#move_back(a:input)
endfunc

func! s:TestClearText(input) abort
  return ve#filter#clear_name(a:input)
endfunc

func! s:TestClearPath(input) abort
  return ve#filter#clear_path(a:input)
endfunc

func! s:TestClearExt(input) abort
  return ve#filter#clear_ext(a:input)
endfunc

func! s:TestClearExtPath(input) abort
  let l:text = ve#filter#clear_ext(a:input)
  let l:text = ve#filter#clear_path(l:text)
  return l:text
endfunc

func! s:TestClearPathExt(input) abort
  let l:text = ve#filter#clear_path(a:input)
  let l:text = ve#filter#clear_ext(l:text)
  return l:text
endfunc

func! s:TestClearExtPath(input) abort
  let l:text = ve#filter#clear_ext(a:input)
  let l:text = ve#filter#clear_path(l:text)
  return l:text
endfunc

func! s:TestClearTextPath(input) abort
  let l:text = ve#filter#clear_name(a:input)
  let l:text = ve#filter#clear_path(l:text)
  return l:text
endfunc

func! s:TestClearPathText(input) abort
  let l:text = ve#filter#clear_path(a:input)
  let l:text = ve#filter#clear_name(l:text)
  return l:text
endfunc

let s:test_count = 0
let s:tests = []

func! s:TestFunction(func_name, repetitions, input, output) abort

  let l:res = a:input
  for l:i in range(0, a:repetitions - 1)
    let l:res = call(function(a:func_name), [l:res])
  endfor

  call add(s:tests, {
                      \ 'function': a:func_name,
                      \ 'input':    a:input,
                      \ 'expects':  a:output,
                      \ 'returned': l:res,
                      \ 'reps':     a:repetitions,
                      \ 'result':   l:res == a:output,
                  \ })

  let s:test_count += 1

endfunc

func! ve#test#run() abort

  let s:test_count = 0
  let s:tests = []

  let l:test_string = 'test.test \te'. g:ve_internal_cursor . 'st\test\ '

  call s:TestFunction('s:TestRemoveCursor',    4, l:test_string, 'test.test \test\test\ ')
  call s:TestFunction('s:TestMoveCursorFront', 4, l:test_string, g:ve_internal_cursor . 'test.test \test\test\ ')
  call s:TestFunction('s:TestMoveCursorBack',  4, l:test_string, 'test.test \test\test\ ' . g:ve_internal_cursor)
  call s:TestFunction('s:TestClearText',       4, l:test_string, g:ve_internal_cursor . ' \test\test\ ')
  call s:TestFunction('s:TestClearPath',       4, l:test_string, 'test.test' . g:ve_internal_cursor)
  call s:TestFunction('s:TestClearExt',        4, l:test_string, 'test.'. g:ve_internal_cursor . ' \test\test\ ')
  call s:TestFunction('s:TestClearExtPath',    4, l:test_string, 'test.'. g:ve_internal_cursor)
  call s:TestFunction('s:TestClearPathExt',    4, l:test_string, 'test.'. g:ve_internal_cursor)
  call s:TestFunction('s:TestClearTextPath',   4, l:test_string, g:ve_internal_cursor)
  call s:TestFunction('s:TestClearPathText',   4, l:test_string, g:ve_internal_cursor)

  echo('Input: ' . l:test_string)

  let l:result = 1

  let l:i = 0
  for e in s:tests

    let l:text = printf("[%d] %sx%d - %d - Returned: %s", l:i, e.function, e.reps, e.result, e.returned)
    if (!e.result)
      let l:text .= printf("- Expected: %s", e.expects)
    endif

    let l:result = l:result && e.result

    let l:i += 1

    echo(l:text)

  endfor

  echo('Tests ended with: ' . l:result)

endfunc
