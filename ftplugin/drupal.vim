" We never :set ft=drupal.  This filetype is always added to another, as in
" :set ft=php.drupal or :set ft=css.drupal.

" The usual variable, b:did_ftplugin, is already set by the ftplugin for the
" primary filetype, so use a custom variable. The Syntastic and tags setting
" above are global, so check them each time we enter the buffer in case they
" have been changed.  Everything below is buffer-local.
if exists("b:did_drupal_ftplugin")  && exists("b:did_ftplugin") | finish | endif
let b:did_drupal_ftplugin = 1

if !exists('*s:OpenURL')

    function s:OpenURL(base)
      let open = b:Drupal_info.OPEN_COMMAND

      if open == ''
        return
      endif

      " Get the word under the cursor.
      let func = expand('<cword>')

      " Some API sites let you specify which Drupal version you want.
      let core = strlen(b:Drupal_info.CORE) ? b:Drupal_info.CORE . '/' : ''

      " Custom processing for several API sites.
      if a:base == 'api.d.o'
        let url = 'http://api.drupal.org/api/search/' . core
      elseif a:base == 'hook'
        let url = 'http://api.drupal.org/api/search/' . core

        " Find the module or theme name and replace it with 'hook'.
        let root = expand('%:t:r')
        let func = substitute(func, '^' . root, 'hook', '')
      elseif a:base == 'drupalcontrib'
        let url = 'http://drupalcontrib.org/api/search/' . core
      else
        let url = a:base
        execute '!' . open . ' ' . a:base . func
      endif

      call system(open . ' ' . url . shellescape(func))
    endfun

endif " !exists('*s:OpenURL')

" Add key maps

if strlen(b:Drupal_info.OPEN_COMMAND)

  " Lookup the API docs for a drupal function under cursor.
  nmap <LocalLeader>da :silent call <SID>OpenURL('api.d.o')<CR><C-L>

  " Lookup the API docs for a drupal hook under cursor.
  nmap <LocalLeader>dh :silent call <SID>OpenURL('hook')<CR><C-L>

  " Lookup the API docs for a contrib function under cursor.
  nmap <LocalLeader>dc :silent call <SID>OpenURL('drupalcontrib')<CR><C-L>

  " Lookup the API docs for a drush function under cursor.
  nmap <LocalLeader>dda :silent call <SID>OpenURL('http://api.drush.ws/api/function/')<CR><C-L>
endif

" Get the value of the drupal variable under cursor.
nnoremap <buffer> <LocalLeader>dv :execute "!drush vget ".shellescape(expand("<cword>"), 1)<CR>
