let SessionLoad = 1
if &cp | set nocp | endif
let s:cpo_save=&cpo
set cpo&vim
inoremap <silent> <Plug>ragtagXmlV ="&#".getchar().";"
inoremap <silent> <Plug>NERDCommenterInsert  <BS>:call NERDComment('i', "insert")
inoremap <Right> <Nop>
inoremap <Left> <Nop>
inoremap <Down> <Nop>
inoremap <Up> <Nop>
map <silent>  :se invhlsearch
nmap ,ca <Plug>NERDCommenterAltDelims
xmap ,cu <Plug>NERDCommenterUncomment
nmap ,cu <Plug>NERDCommenterUncomment
xmap ,cb <Plug>NERDCommenterAlignBoth
nmap ,cb <Plug>NERDCommenterAlignBoth
xmap ,cl <Plug>NERDCommenterAlignLeft
nmap ,cl <Plug>NERDCommenterAlignLeft
nmap ,cA <Plug>NERDCommenterAppend
xmap ,cy <Plug>NERDCommenterYank
nmap ,cy <Plug>NERDCommenterYank
xmap ,cs <Plug>NERDCommenterSexy
nmap ,cs <Plug>NERDCommenterSexy
xmap ,ci <Plug>NERDCommenterInvert
nmap ,ci <Plug>NERDCommenterInvert
nmap ,c$ <Plug>NERDCommenterToEOL
xmap ,cn <Plug>NERDCommenterNested
nmap ,cn <Plug>NERDCommenterNested
xmap ,cm <Plug>NERDCommenterMinimal
nmap ,cm <Plug>NERDCommenterMinimal
xmap ,c  <Plug>NERDCommenterToggle
nmap ,c  <Plug>NERDCommenterToggle
xmap ,cc <Plug>NERDCommenterComment
nmap ,cc <Plug>NERDCommenterComment
nmap <silent> ,slr :DBListVar
xmap <silent> ,sa :DBVarRangeAssign
nmap <silent> ,sap :'<,'>DBVarRangeAssign
nmap <silent> ,sal :.,.DBVarRangeAssign
nmap <silent> ,sas :1,$DBVarRangeAssign
nmap ,so <Plug>DBOrientationToggle
nmap ,sh <Plug>DBHistory
xmap <silent> ,stcl :exec "DBListColumn '".DB_getVisualBlock()."'"
nmap ,stcl <Plug>DBListColumn
nmap ,slv <Plug>DBListView
nmap ,slp <Plug>DBListProcedure
nmap ,slt <Plug>DBListTable
xmap <silent> ,slc :exec "DBListColumn '".DB_getVisualBlock()."'"
nmap ,slc <Plug>DBListColumn
nmap ,sbp <Plug>DBPromptForBufferParameters
nmap ,sdpa <Plug>DBDescribeProcedureAskName
xmap <silent> ,sdp :exec "DBDescribeProcedure '".DB_getVisualBlock()."'"
nmap ,sdp <Plug>DBDescribeProcedure
nmap ,sdta <Plug>DBDescribeTableAskName
xmap <silent> ,sdt :exec "DBDescribeTable '".DB_getVisualBlock()."'"
nmap ,sdt <Plug>DBDescribeTable
xmap <silent> ,sT :exec "DBSelectFromTableTopX '".DB_getVisualBlock()."'"
nmap ,sT <Plug>DBSelectFromTopXTable
nmap ,sta <Plug>DBSelectFromTableAskName
nmap ,stw <Plug>DBSelectFromTableWithWhere
xmap <silent> ,st :exec "DBSelectFromTable '".DB_getVisualBlock()."'"
nmap ,st <Plug>DBSelectFromTable
nmap <silent> ,sep :'<,'>DBExecRangeSQL
nmap <silent> ,sel :.,.DBExecRangeSQL
nmap <silent> ,sea :1,$DBExecRangeSQL
nmap ,sq <Plug>DBExecSQL
nmap ,sE <Plug>DBExecSQLUnderTopXCursor
nmap ,se <Plug>DBExecSQLUnderCursor
xmap ,sE <Plug>DBExecVisualTopXSQL
xmap ,se <Plug>DBExecVisualSQL
nnoremap ,W :%s/\s\+$//:let @/=''
map <silent> ,rt :!ctags --extra=+f --exclude=.git --exclude=log -R * `gem environment gemdir`/gems/*
nnoremap ,a :Ack
nnoremap ,0  :10b
nnoremap ,9  :9b
nnoremap ,8  :8b
nnoremap ,7  :7b
nnoremap ,6  :6b
nnoremap ,5  :5b
nnoremap ,4  :4b
nnoremap ,3  :3b
nnoremap ,2  :2b
nnoremap ,1  :1b
nnoremap ,g  :e#
nnoremap ,f  :bn
nnoremap ,b  :bp
nnoremap ,l  :ls
noremap ,t :!ctags --tag-relative -Rf.git/tags.$$ --exclude=.git --exclude=log --exclude=public --exclude=app/stylesheets * $(rvm gemset dir)/*;fg;mv .git/tags.$$ .git/tags;rm -f .git/tags.$$
nnoremap ,  :noh
map ,r :source ~/.vim/.session
map ,s :mksession! ~/.vim/.session
vnoremap / /\v
nnoremap / /\v
xmap S <Plug>VSurround
vmap [% [%m'gv``
vmap ]% ]%m'gv``
vmap a% [%v]%
nmap cs <Plug>Csurround
nmap cr <Plug>Coerce
nmap ds <Plug>Dsurround
nmap gx <Plug>NetrwBrowseX
xmap gS <Plug>VgSurround
nnoremap j gj
nnoremap k gk
nmap ySS <Plug>YSsurround
nmap ySs <Plug>YSsurround
nmap yss <Plug>Yssurround
nmap yS <Plug>YSurround
nmap ys <Plug>Ysurround
nnoremap <silent> <Plug>NetrwBrowseX :call netrw#NetrwBrowseX(expand("<cWORD>"),0)
nnoremap <silent> <Plug>SurroundRepeat .
xnoremap <silent> <Plug>NERDCommenterUncomment :call NERDComment("x", "Uncomment")
nnoremap <silent> <Plug>NERDCommenterUncomment :call NERDComment("n", "Uncomment")
xnoremap <silent> <Plug>NERDCommenterAlignBoth :call NERDComment("x", "AlignBoth")
nnoremap <silent> <Plug>NERDCommenterAlignBoth :call NERDComment("n", "AlignBoth")
xnoremap <silent> <Plug>NERDCommenterAlignLeft :call NERDComment("x", "AlignLeft")
nnoremap <silent> <Plug>NERDCommenterAlignLeft :call NERDComment("n", "AlignLeft")
nnoremap <silent> <Plug>NERDCommenterAppend :call NERDComment("n", "Append")
xnoremap <silent> <Plug>NERDCommenterYank :call NERDComment("x", "Yank")
nnoremap <silent> <Plug>NERDCommenterYank :call NERDComment("n", "Yank")
xnoremap <silent> <Plug>NERDCommenterSexy :call NERDComment("x", "Sexy")
nnoremap <silent> <Plug>NERDCommenterSexy :call NERDComment("n", "Sexy")
xnoremap <silent> <Plug>NERDCommenterInvert :call NERDComment("x", "Invert")
nnoremap <silent> <Plug>NERDCommenterInvert :call NERDComment("n", "Invert")
nnoremap <silent> <Plug>NERDCommenterToEOL :call NERDComment("n", "ToEOL")
xnoremap <silent> <Plug>NERDCommenterNested :call NERDComment("x", "Nested")
nnoremap <silent> <Plug>NERDCommenterNested :call NERDComment("n", "Nested")
xnoremap <silent> <Plug>NERDCommenterMinimal :call NERDComment("x", "Minimal")
nnoremap <silent> <Plug>NERDCommenterMinimal :call NERDComment("n", "Minimal")
xnoremap <silent> <Plug>NERDCommenterToggle :call NERDComment("x", "Toggle")
nnoremap <silent> <Plug>NERDCommenterToggle :call NERDComment("n", "Toggle")
xnoremap <silent> <Plug>NERDCommenterComment :call NERDComment("x", "Comment")
nnoremap <silent> <Plug>NERDCommenterComment :call NERDComment("n", "Comment")
nnoremap <Right> <Nop>
nnoremap <Left> <Nop>
nnoremap <Down> <Nop>
nnoremap <Up> <Nop>
nnoremap <F10> :b 
nnoremap <F5> :buffers:buffer 
nnoremap <silent> <F7> :NERDTreeToggle 
nmap <silent> <M-Down> :wincmd j
nmap <silent> <M-Up> :wincmd k
nmap <F8> :TagbarToggle 
imap S <Plug>ISurround
imap s <Plug>Isurround
imap  <Plug>DiscretionaryEnd
imap  <Plug>Isurround
imap  <Plug>AlwaysEnd
let &cpo=s:cpo_save
unlet s:cpo_save
set paste
set autoindent
set backspace=indent,eol,start
set expandtab
set fileencodings=ucs-bom,utf-8,default,latin1
set guioptions=aegirLt
set helplang=es
set hidden
set ignorecase
set indentkeys=o,O,*<Return>,<>>,{,},0),0],o,O,!^F,=end,=else,=elsif,=rescue,=ensure,=when
set iskeyword=@,48-57,_,192-255,$
set laststatus=2
set pastetoggle=<F5>
set printoptions=paper:a4
set runtimepath=~/.vim,~/.vim/bundle/nerdtree,~/.vim/bundle/pathogen,~/.vim/bundle/peaksea,~/.vim/bundle/svg.vim,~/.vim/bundle/vim-abolish.git,~/.vim/bundle/vim-ack,~/.vim/bundle/vim-bufexplorer,~/.vim/bundle/vim-colors-solarized,~/.vim/bundle/vim-dbext,~/.vim/bundle/vim-endwise,~/.vim/bundle/vim-eunuch,~/.vim/bundle/vim-fugitive,~/.vim/bundle/vim-haml,~/.vim/bundle/vim-misc,~/.vim/bundle/vim-nerdcommenter,~/.vim/bundle/vim-notes,~/.vim/bundle/vim-ragtag,~/.vim/bundle/vim-rails,~/.vim/bundle/vim-repeat,~/.vim/bundle/vim-session,~/.vim/bundle/vim-surround,~/.vim/bundle/vim-tagbar,/var/lib/vim/addons,/usr/share/vim/vimfiles,/usr/share/vim/vim73,/usr/share/vim/vimfiles/after,/var/lib/vim/addons/after,~/.vim/after
set scrolloff=5
set shiftwidth=2
set showtabline=2
set smartcase
set smartindent
set softtabstop=2
set statusline=%02n:%<%f\ %h%m%r%=%-14.(%l,%c%V%)\ %P
set suffixes=.bak,~,.swp,.o,.info,.aux,.log,.dvi,.bbl,.blg,.brf,.cb,.ind,.idx,.ilg,.inx,.out,.toc
set tabstop=2
set undofile
set viminfo='100,f1
set wildcharm=26
set wildmenu
let s:so_save = &so | let s:siso_save = &siso | set so=0 siso=0
let v:this_session=expand("<sfile>:p")
silent only
cd ~/lascar
if expand('%') == '' && !&modified && line('$') <= 1 && getline(1) == ''
  let s:wipebuf = bufnr('%')
endif
set shortmess=aoO
badd +1 app/controllers/elements_controller.rb
badd +118 app/assets/javascripts/lascar.js
badd +23 app/views/layouts/application.html.erb
badd +31 app/assets/stylesheets/application.css.scss
args app/controllers/elements_controller.rb app/assets/javascripts/lascar.js
edit app/assets/javascripts/lascar.js
set splitbelow splitright
set nosplitbelow
set nosplitright
wincmd t
set winheight=1 winwidth=1
argglobal
edit app/assets/javascripts/lascar.js
let s:cpo_save=&cpo
set cpo&vim
nmap <buffer> gf <Plug>RailsTabFind
nmap <buffer> f <Plug>RailsSplitFind
nmap <buffer> gf <Plug>RailsFind
let &cpo=s:cpo_save
unlet s:cpo_save
setlocal keymap=
setlocal noarabic
setlocal autoindent
setlocal balloonexpr=
setlocal nobinary
setlocal bufhidden=
setlocal buflisted
setlocal buftype=
setlocal cindent
setlocal cinkeys=0{,0},0),:,0#,!^F,o,O,e
setlocal cinoptions=j1,J1
setlocal cinwords=if,else,while,do,for,switch
setlocal colorcolumn=
setlocal comments=sO:*\ -,mO:*\ \ ,exO:*/,s1:/*,mb:*,ex:*/,://
setlocal commentstring=//%s
setlocal complete=.,w,b,u,t,i
setlocal concealcursor=
setlocal conceallevel=0
setlocal completefunc=
setlocal nocopyindent
setlocal cryptmethod=
setlocal nocursorbind
setlocal nocursorcolumn
setlocal nocursorline
setlocal define=
setlocal dictionary=
setlocal nodiff
setlocal equalprg=
setlocal errorformat=
setlocal expandtab
if &filetype != 'javascript'
setlocal filetype=javascript
endif
setlocal foldcolumn=0
setlocal foldenable
setlocal foldexpr=0
setlocal foldignore=#
setlocal foldlevel=0
setlocal foldmarker={{{,}}}
setlocal foldmethod=manual
setlocal foldminlines=1
setlocal foldnestmax=20
setlocal foldtext=foldtext()
setlocal formatexpr=
setlocal formatoptions=croql
setlocal formatlistpat=^\\s*\\d\\+[\\]:.)}\\t\ ]\\s*
setlocal grepprg=
setlocal iminsert=2
setlocal imsearch=2
setlocal include=
setlocal includeexpr=RailsIncludeexpr()
setlocal indentexpr=
setlocal indentkeys=0{,0},:,0#,!^F,o,O,e
setlocal noinfercase
setlocal iskeyword=@,48-57,_,192-255,$
setlocal keywordprg=
setlocal nolinebreak
setlocal nolisp
setlocal nolist
setlocal makeprg=
setlocal matchpairs=(:),{:},[:]
setlocal modeline
setlocal modifiable
setlocal nrformats=octal,hex
setlocal nonumber
setlocal numberwidth=4
setlocal omnifunc=javascriptcomplete#CompleteJS
setlocal path=.,lib,vendor,app/models/concerns,app/controllers/concerns,app/controllers,app/helpers,app/mailers,app/models,app/*,app/views,app/views/lascar,public,test,test/unit,test/functional,test/integration,test/controllers,test/helpers,test/mailers,test/models,vendor/plugins/*/lib,vendor/plugins/*/test,vendor/rails/*/lib,vendor/rails/*/test,~/lascar,/usr/include,
setlocal nopreserveindent
setlocal nopreviewwindow
setlocal quoteescape=\\
setlocal noreadonly
setlocal norelativenumber
setlocal norightleft
setlocal rightleftcmd=search
setlocal noscrollbind
setlocal shiftwidth=2
setlocal noshortname
setlocal smartindent
setlocal softtabstop=2
setlocal nospell
setlocal spellcapcheck=[.?!]\\_[\\])'\"\	\ ]\\+
setlocal spellfile=
setlocal spelllang=en
setlocal statusline=
setlocal suffixesadd=.rb
setlocal swapfile
setlocal synmaxcol=3000
if &syntax != 'javascript'
setlocal syntax=javascript
endif
setlocal tabstop=2
setlocal tags=~/lascar/tags,~/lascar/tmp/tags,~/lascar/.git/javascript.tags,~/lascar/.git/tags,./tags,./TAGS,tags,TAGS
setlocal textwidth=0
setlocal thesaurus=
setlocal undofile
setlocal nowinfixheight
setlocal nowinfixwidth
setlocal wrap
setlocal wrapmargin=0
silent! normal! zE
let s:l = 118 - ((18 * winheight(0) + 25) / 50)
if s:l < 1 | let s:l = 1 | endif
exe s:l
normal! zt
118
normal! 08l
tabnext 1
if exists('s:wipebuf')
  silent exe 'bwipe ' . s:wipebuf
endif
unlet! s:wipebuf
set winheight=1 winwidth=20 shortmess=filnxtToO
let s:sx = expand("<sfile>:p:r")."x.vim"
if file_readable(s:sx)
  exe "source " . fnameescape(s:sx)
endif
let &so = s:so_save | let &siso = s:siso_save
doautoall SessionLoadPost
unlet SessionLoad
" vim: set ft=vim :
