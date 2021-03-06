" Bundles:
call plug#begin('~/.vim/bundle')

"" Early dependencies
Plug 'MarcWeber/vim-addon-mw-utils'
Plug 'tomtom/tlib_vim'
Plug 'honza/vim-snippets'

"" Other
Plug 'edsono/vim-matchit'
Plug 'scrooloose/nerdtree'
Plug 'ctrlpvim/ctrlp.vim'
Plug 'majutsushi/tagbar'
Plug 'mbbill/undotree'
Plug 'scrooloose/nerdcommenter'
Plug 'benekastah/neomake' " Replaces syntastic
Plug 'tpope/vim-surround'
Plug 'junegunn/goyo.vim'
Plug 'junegunn/limelight.vim' " Highlight active paragraph
Plug 'tpope/vim-fugitive' " For gitv
Plug 'gregsexton/gitv' " gitk for vim
Plug 'jeetsukumaran/vim-indentwise' " Indent-based jumps
Plug 'alvan/vim-closetag' " Auto-close HTML tags
Plug 'itchyny/lightline.vim'

"" Language support
Plug 'Shougo/deoplete.nvim' " Replaces neocomplcache
Plug 'Shougo/neosnippet'
Plug 'janko-m/vim-test'
Plug 'leshill/vim-json'
Plug 'plasticboy/vim-markdown'
Plug 'hdima/python-syntax'
Plug 'hynek/vim-python-pep8-indent'
Plug 'davidhalter/jedi-vim' " Python static analysis engine
Plug 'jmcantrell/vim-virtualenv'
if $GOPATH != ""
    Plug 'zchee/deoplete-go'
    Plug 'fatih/vim-go'
    Plug 'rhysd/vim-go-impl'
endif
if executable('rustc')
    Plug 'rust-lang/rust.vim'
endif

"" Syntax highlighting
Plug 'hail2u/vim-css3-syntax'
Plug 'pangloss/vim-javascript'
Plug 'othree/html5.vim'
Plug 'ap/vim-css-color'
Plug 'sophacles/vim-bundle-mako', { 'for': 'mako' }
Plug 'groenewege/vim-less', { 'for': 'less' }
Plug 'honza/dockerfile.vim'
Plug 'tikhomirov/vim-glsl', { 'for': 'glsl' }
Plug 'vim-scripts/rfc-syntax', { 'for': 'rfc' } " optional syntax highlighting for RFC files
Plug 'cespare/vim-toml'

"" Colorschemes
Plug 'freeo/vim-kalisi'


"" Extra local bundles
if filereadable(expand("~/.vimrc.bundles"))
    source ~/.vimrc.bundles
endif

" Done adding plugins
call plug#end()


"" AutoCloseTag
let g:closetag_filenames = "*.html,*.xml,*.mako"

" Matchit
autocmd FileType mako let b:match_words = '<\(\w\w*\):</\1,{:}'

" ctrlp {
    let g:ctrlp_cmd = 'CtrlPMixed' " Search all the things.
    let g:ctrlp_working_path_mode = 'ra' " Nearest ancestor
    let g:ctrlp_mruf_max = 25
    let g:ctrlp_custom_ignore = {
        \ 'dir':  '\.git$\|\.hg$\|\.svn$',
        \ 'file': '\.exe$\|\.so$\|\.dll$' }

    let g:ctrlp_user_command = {
        \ 'types': {
            \ 1: ['.git', 'cd %s && git ls-files . --cached --exclude-standard --others'],
            \ 2: ['.hg', 'hg --cwd %s locate -I .'],
        \ },
        \ 'fallback': 'find %s -type f'
    \ }
    " Reuse already-open buffers? (Default: 'Et')
    let g:ctrlp_switch_buffer = 0

    nnoremap <silent> <D-p> :CtrlP<CR>
    nnoremap <silent> <D-r> :CtrlPMRU<CR>
    nnoremap <leader>p :CtrlPTag<cr> " Ctags integration
"}

" OmniComplete {
    if has("autocmd") && exists("+omnifunc")
        autocmd Filetype *
            \if &omnifunc == "" |
            \setlocal omnifunc=syntaxcomplete#Complete |
            \endif
    endif

    hi Pmenu  guifg=#000000 guibg=#F8F8F8 ctermfg=black ctermbg=Lightgray
    hi PmenuSbar  guifg=#8A95A7 guibg=#F8F8F8 gui=NONE ctermfg=darkcyan ctermbg=lightgray cterm=NONE
    hi PmenuThumb  guifg=#F8F8F8 guibg=#8A95A7 gui=NONE ctermfg=lightgray ctermbg=darkcyan cterm=NONE

    " Some convenient mappings
    inoremap <expr><CR>       pumvisible() ? "\<C-y>" : "\<CR>"
    inoremap <expr><Down>     pumvisible() ? "\<C-n>" : "\<Down>"
    inoremap <expr><Up>       pumvisible() ? "\<C-p>" : "\<Up>"

    " Automatically open and close the popup menu / preview window
    au CursorMovedI,InsertLeave * if pumvisible() == 0|silent! pclose|endif
    set completeopt=menu,preview,longest

    " Enable omni completion.
    autocmd FileType css setlocal omnifunc=csscomplete#CompleteCSS
    autocmd FileType html,markdown setlocal omnifunc=htmlcomplete#CompleteTags
    autocmd FileType javascript setlocal omnifunc=javascriptcomplete#CompleteJS
    "autocmd FileType python setlocal omnifunc=pythoncomplete#Complete
    autocmd FileType python setlocal omnifunc=jedi#completions
    autocmd FileType xml setlocal omnifunc=xmlcomplete#CompleteTags
    autocmd FileType ruby setlocal omnifunc=rubycomplete#Complete
" }

" deoplete {
    let g:deoplete#enable_at_startup = 1
    let g:deoplete#auto_completion_start_length = 3

    " deoplete-go
    set completeopt+=noinsert
    set completeopt+=noselect

    " Tab-complete, without completing on an empty line.
    function! s:check_back_space()
      let col = col('.') - 1
      return !col || getline('.')[col - 1] =~ '\s'
    endfunction

    function! s:tab_complete()
        " Are we already completing?
        if pumvisible()
            return "\<C-n>"
        endif

        " Is it a snippet?
        if neosnippet#expandable_or_jumpable()
            return "\<Plug>(neosnippet_expand_or_jump)"
        endif

        return "\<TAB>"

        " No longer needed?
        "
        "" Are we on an empty line?
        "let col = col('.') - 1
        "if !col || getline('.')[col - 1] =~ '\s'
        "    return "\<TAB>"
        "endif
        "" Let deoplete do its thing.
        "return deoplete#mappings#manual_complete()
    endfunction

    imap <silent><expr> <TAB> <SID>tab_complete()

    " doplete + vim-jedi for Python
    let g:jedi#completions_enabled = 0
    let g:jedi#auto_vim_configuration = 0
    let g:jedi#smart_auto_mappings = 0
    let g:jedi#show_call_signatures = 0
" }

" neosnippet {
    imap <C-k> <Right><Plug>(neosnippet_expand_or_jump)
    smap <C-k> <Right><Plug>(neosnippet_expand_or_jump)

    " Use honza's snippets.
    let g:neosnippet#snippets_directory='~/.vim/bundle/vim-snippets/snippets'

    " Enable neosnippet snipmate compatibility mode
    let g:neosnippet#enable_snipmate_compatibility = 1

    " Disable runtime snippets
    let g:neosnippet#disable_runtime_snippets = { "_": 1, }

    " For snippet_complete marker.
    if has('conceal')
        set conceallevel=2 concealcursor=i
    endif

    " Disable the neosnippet preview candidate window
    " When enabled, there can be too much visual noise
    " especially when splits are used.
    set completeopt-=preview
" }

" UndoTree {
    nnoremap <Leader>u :UndotreeToggle<CR>
    " If undotree is opened, it is likely one wants to interact with it.
    let g:undotree_SetFocusWhenToggle=1
" }

" Tagbar {
    nmap <leader>ta :TagbarToggle<CR>

    let g:tagbar_type_go = {
        \ 'ctagstype' : 'go',
        \ 'kinds'     : [
            \ 'p:package',
            \ 'i:imports:1',
            \ 'c:constants',
            \ 'v:variables',
            \ 't:types',
            \ 'n:interfaces',
            \ 'w:fields',
            \ 'e:embedded',
            \ 'm:methods',
            \ 'r:constructor',
            \ 'f:functions'
        \ ],
        \ 'sro' : '.',
        \ 'kind2scope' : {
            \ 't' : 'ctype',
            \ 'n' : 'ntype'
        \ },
        \ 'scope2kind' : {
            \ 'ctype' : 't',
            \ 'ntype' : 'n'
        \ },
        \ 'ctagsbin'  : 'gotags',
        \ 'ctagsargs' : '-sort -silent'
    \ }
" }

" vim-go
autocmd FileType go setlocal noexpandtab shiftwidth=4 tabstop=4 softtabstop=4

au FileType go nmap <leader>gd <Plug>(go-doc)
au FileType go nmap <leader>gv <Plug>(go-doc-vertical)
au FileType go nmap <Leader>gb <Plug>(go-doc-browser)
au FileType go nmap <leader>b <Plug>(go-build)
au FileType go nmap <leader>ru <Plug>(go-run)
au FileType go nmap <leader>re <Plug>(go-rename)
au FileType go nmap <leader>te <plug>(go-test)
au FileType go nmap <leader>in <Plug>(go-info)
au FileType go nmap <leader>ii <Plug>(go-implements)
au FileType go nmap gd <Plug>(go-def-split)
au FileType go nmap gD <Plug>(go-def)

let g:go_def_mapping_enabled = 0
let g:go_fmt_command = "goimports"
let g:go_test_timeout = "3s"

" vim-markdown
let g:vim_markdown_folding_disabled=1
let g:vim_markdown_frontmatter = 1
au FileType markdown nmap <leader>t :Toc<CR>
au FileType markdown setlocal formatoptions+=want textwidth=80 linebreak "spell complete+=kspell
autocmd BufNewFile,BufReadPost *.md set filetype=markdown

" goyo (zenroom)
let g:goyo_width=82
nnoremap <Leader>z :Goyo<CR>

" neomake
autocmd! BufWritePost *.py Neomake

" lightline
set laststatus=2
set noshowmode " Hide INSERT etc

"" Borrowed from fatih/dotfiles
let g:lightline = {
      \ 'colorscheme': 'jellybeans',
      \ 'subseparator': { 'left': '', 'right': '' },
      \ 'active': {
      \   'left': [ [ 'filename' ],
      \             [ 'job'] ],
      \   'right': [ [ 'lineinfo' ],
      \              [ 'percent' ],
      \              [ 'filetype' ] ]
      \ },
      \ 'inactive': {
      \   'left': [ [ 'filename'] ],
      \ },
      \ 'component_function': {
      \   'modified': 'LightLineModified',
      \   'filename': 'LightLineFilename',
      \   'job': 'LightLineJob',
      \   'filetype': 'LightLineFiletype',
      \ },
      \ }

function! LightLineModified()
  if &filetype == "help"
    return ""
  elseif &modified
    return "+"
  elseif &modifiable
    return ""
  else
    return ""
  endif
endfunction

function! LightLineFiletype()
  return winwidth(0) > 70 ? (strlen(&filetype) ? &filetype : 'no ft') : ''
endfunction

function! LightLineJob()
  return exists('*go#jobcontrol#Statusline') ? go#jobcontrol#Statusline() : ''
endfunction

function! LightLineMode()
  let fname = expand('%:t')
  return fname == 'ControlP' ? 'CtrlP' :
        \ fname =~ 'NERD_tree' ? 'NERDTree' :
        \ winwidth(0) > 60 ? lightline#mode() : ''
endfunction

function! LightLineFilename()
    let out = ''
    if mode() == 't'
        return out
    endif

    " fugitive-aware repo path
    let rootpath = ''
    if exists("*fugitive#head")
        let branch = fugitive#head()
        if strlen(branch)
            let rootpath = fugitive#repo().tree()
            let out .= '[' . branch . '] ' . fnamemodify(rootpath, ':t')
        endif
    endif

    let fname = expand('%:t')
    if fname == '' || fname =~ 'ControlP\|NERD_tree'
        " Nothing
    elseif strlen(rootpath) > 0
        " /usr/src/myrepo - /usr/src/myrepo/subdir/foo = subdir/foo
        let out .= '/' . strpart(expand('%:p'), len(rootpath) + 1)
    else
        " ~/myrepo/subdir/foo
        let out = expand('%:p:~')
    endif
    return ('' != LightLineReadonly() ? LightLineReadonly() . ' ' : '') .
                \ out .
                \ ('' != LightLineModified() ? ' ' . LightLineModified() : '')
endfunction

function! LightLineReadonly()
  return &ft !~? 'help' && &readonly ? '🔒 ' : ''
endfunction
