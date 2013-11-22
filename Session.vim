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
badd +54 app/assets/javascripts/lascar.js
badd +17 app/views/elements/list.js.erb
badd +0 app/views/elements/show.js.erb
badd +2 config/routes.rb
badd +13 app/views/layouts/application.html.haml
args app/controllers/elements_controller.rb app/assets/javascripts/lascar.js app/views/elements/list.js.erb app/views/elements/show.js.erb config/routes.rb app/views/layouts/application.html.haml
edit app/views/layouts/application.html.haml
set splitbelow splitright
set nosplitbelow
set nosplitright
wincmd t
set winheight=1 winwidth=1
argglobal
edit app/views/layouts/application.html.haml
let s:cpo_save=&cpo
set cpo&vim
nmap <buffer> gf <Plug>RailsTabFind
nmap <buffer> f <Plug>RailsSplitFind
nnoremap <buffer> <silent> g} :exe        "ptjump =RubyCursorIdentifier()"
nnoremap <buffer> <silent> } :exe          "ptag =RubyCursorIdentifier()"
nnoremap <buffer> <silent> g] :exe      "stselect =RubyCursorIdentifier()"
nnoremap <buffer> <silent> g :exe        "stjump =RubyCursorIdentifier()"
nnoremap <buffer> <silent>  :exe v:count1."stag =RubyCursorIdentifier()"
nnoremap <buffer> <silent> ] :exe v:count1."stag =RubyCursorIdentifier()"
nnoremap <buffer> <silent>  :exe  v:count1."tag =RubyCursorIdentifier()"
nmap <buffer> gf <Plug>RailsFind
nnoremap <buffer> <silent> g] :exe       "tselect =RubyCursorIdentifier()"
nnoremap <buffer> <silent> g :exe         "tjump =RubyCursorIdentifier()"
let &cpo=s:cpo_save
unlet s:cpo_save
setlocal keymap=
setlocal noarabic
setlocal autoindent
setlocal balloonexpr=RubyBalloonexpr()
setlocal nobinary
setlocal bufhidden=
setlocal buflisted
setlocal buftype=
setlocal nocindent
setlocal cinkeys=0{,0},0),:,0#,!^F,o,O,e
setlocal cinoptions=
setlocal cinwords=if,else,while,do,for,switch
setlocal colorcolumn=
setlocal comments=
setlocal commentstring=-#\ %s
setlocal complete=.,w,b,u,t,i
setlocal concealcursor=
setlocal conceallevel=0
setlocal completefunc=syntaxcomplete#Complete
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
if &filetype != 'haml'
setlocal filetype=haml
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
setlocal include=^\\s*\\<\\(load\\|w*require\\)\\>
setlocal includeexpr=RailsIncludeexpr()
setlocal indentexpr=GetHamlIndent()
setlocal indentkeys=o,O,*<Return>,},],0),!^F,=end,=else,=elsif,=rescue,=ensure,=when
setlocal noinfercase
setlocal iskeyword=@,48-57,_,192-255,$
setlocal keywordprg=ri
setlocal nolinebreak
setlocal nolisp
setlocal nolist
setlocal makeprg=
setlocal matchpairs=(:),{:},[:]
setlocal modeline
setlocal modifiable
setlocal nrformats=octal,hex
set number
setlocal number
setlocal numberwidth=4
setlocal omnifunc=rubycomplete#Complete
setlocal path=.,lib,vendor,app/models/concerns,app/controllers/concerns,app/controllers,app/helpers,app/mailers,app/models,app/*,app/views,app/views/application,public,test,test/unit,test/functional,test/integration,test/controllers,test/helpers,test/mailers,test/models,vendor/plugins/*/lib,vendor/plugins/*/test,vendor/rails/*/lib,vendor/rails/*/test,~/lascar,NOTE:\\\ Gem.all_load_paths\\\ is\\\ deprecated\\\ with\\\ no\\\ replacement.\\\ It\\\ will\\\ be\\\ removed\\\ on\\\ or\\\ after\\\ 2011-10-01.\
Gem.all_load_paths\\\ called\\\ from\\\ -e:1.\
NOTE:\\\ Gem.all_partials\\\ is\\\ deprecated\\\ with\\\ no\\\ replacement.\\\ It\\\ will\\\ be\\\ removed\\\ on\\\ or\\\ after\\\ 2011-10-01.\
Gem.all_partials\\\ called\\\ from\\\ ~/.rvm/rubies/ruby-1.9.3-p327/lib/ruby/site_ruby/1.9.1/rubygems.rb:261.\
NOTE:\\\ Gem.all_partials\\\ is\\\ deprecated\\\ with\\\ no\\\ replacement.\\\ It\\\ will\\\ be\\\ removed\\\ on\\\ or\\\ after\\\ 2011-10-01.\
Gem.all_partials\\\ called\\\ from\\\ ~/.rvm/rubies/ruby-1.9.3-p327/lib/ruby/site_ruby/1.9.1/rubygems.rb:261.\
/home/pascal/.rvm/rubies/ruby-1.9.3-p327/lib/ruby/site_ruby/1.9.1,~/.rvm/rubies/ruby-1.9.3-p327/lib/ruby/site_ruby/1.9.1/x86_64-linux,~/.rvm/rubies/ruby-1.9.3-p327/lib/ruby/site_ruby,~/.rvm/rubies/ruby-1.9.3-p327/lib/ruby/vendor_ruby/1.9.1,~/.rvm/rubies/ruby-1.9.3-p327/lib/ruby/vendor_ruby/1.9.1/x86_64-linux,~/.rvm/rubies/ruby-1.9.3-p327/lib/ruby/vendor_ruby,~/.rvm/rubies/ruby-1.9.3-p327/lib/ruby/1.9.1,~/.rvm/rubies/ruby-1.9.3-p327/lib/ruby/1.9.1/x86_64-linux,~/.rvm/gems/ruby-1.9.3-p327@global/gems/bundler-1.3.5/lib,~/.rvm/gems/ruby-1.9.3-p327@global/gems/bundler-unload-1.0.1/lib,~/.rvm/gems/ruby-1.9.3-p327@global/gems/rake-10.0.4/lib,~/.rvm/gems/ruby-1.9.3-p327@global/gems/rubygems-bundler-1.2.0/lib,~/.rvm/gems/ruby-1.9.3-p327@global/gems/rvm-1.11.3.8/lib,~/.rvm/gems/ruby-1.9.3-p327@lascar/gems/actionmailer-4.0.0/lib,~/.rvm/gems/ruby-1.9.3-p327@lascar/gems/actionpack-4.0.0/lib,~/.rvm/gems/ruby-1.9.3-p327@lascar/gems/activemodel-4.0.0/lib,~/.rvm/gems/ruby-1.9.3-p327@lascar/gems/activerecord-4.0.0/lib,~/.rvm/gems/ruby-1.9.3-p327@lascar/gems/activerecord-deprecated_finders-1.0.3/lib,~/.rvm/gems/ruby-1.9.3-p327@lascar/gems/activesupport-4.0.0/lib,~/.rvm/gems/ruby-1.9.3-p327@lascar/gems/arel-4.0.1/lib,~/.rvm/gems/ruby-1.9.3-p327@lascar/gems/atomic-1.1.14/lib,~/.rvm/gems/ruby-1.9.3-p327@lascar/gems/builder-3.1.4/lib,~/.rvm/gems/ruby-1.9.3-p327@lascar/gems/chunky_png-1.2.9/lib,~/.rvm/gems/ruby-1.9.3-p327@lascar/gems/coffee-rails-4.0.1/lib,~/.rvm/gems/ruby-1.9.3-p327@lascar/gems/coffee-script-2.2.0/lib,~/.rvm/gems/ruby-1.9.3-p327@lascar/gems/coffee-script-source-1.6.3/lib,~/.rvm/gems/ruby-1.9.3-p327@lascar/gems/columnize-0.3.6/lib,~/.rvm/gems/ruby-1.9.3-p327@lascar/gems/compass-0.12.2/lib,~/.rvm/gems/ruby-1.9.3-p327@lascar/gems/compass-rails-2.0.alpha.0/lib,~/.rvm/gems/ruby-1.9.3-p327@lascar/gems/debugger-1.6.2/lib,~/.rvm/gems/ruby-1.9.3-p327@lascar/gems/debugger-linecache-1.2.0/lib,~/.rvm/gems/ruby-1.9.3-p327@lascar/gems/debugger-ruby_core_source-1.2.3/lib,~/.rvm/gems/ruby-1.9.3-p327@lascar/gems/erubis-2.7.0/lib,~/.rvm/gems/ruby-1.9.3-p327@lascar/gems/execjs-2.0.2/lib,~/.rvm/gems/ruby-1.9.3-p327@lascar/gems/fssm-0.2.10/lib,~/.rvm/gems/ruby-1.9.3-p327@lascar/gems/haml-4.0.3/lib,~/.rvm/gems/ruby-1.9.3-p327@lascar/gems/haml-contrib-1.0.0.1/lib,~/.rvm/gems/ruby-1.9.3-p327@lascar/gems/haml-rails-0.4/lib,~/.rvm/gems/ruby-1.9.3-p327@lascar/gems/hike-1.2.3/lib,~/.rvm/gems/ruby-1.9.3-p327@lascar/gems/hpricot-0.8.6/lib,~/.rvm/gems/ruby-1.9.3-p327@lascar/gems/html2haml-1.0.1/lib,~/.rvm/gems/ruby-1.9.3-p327@lascar/gems/i18n-0.6.5/lib,~/.rvm/gems/ruby-1.9.3-p327@lascar/gems/jbuilder-1.5.2/lib,~/.rvm/gems/ruby-1.9.3-p327@lascar/gems/jquery-rails-3.0.4/lib,~/.rvm/gems/ruby-1.9.3-p327@lascar/gems/json-1.8.1/lib,~/.rvm/gems/ruby-1.9.3-p327@lascar/gems/mail-2.5.4/lib,~/.rvm/gems/ruby-1.9.3-p327@lascar/gems/mime-types-1.25/lib,~/.rvm/gems/ruby-1.9.3-p327@lascar/gems/minitest-4.7.5/lib,~/.rvm/gems/ruby-1.9.3-p327@lascar/gems/multi_json-1.8.2/lib,~/.rvm/gems/ruby-1.9.3-p327@lascar/gems/polyglot-0.3.3/lib,~/.rvm/gems/ruby-1.9.3-p327@lascar/gems/rack-1.5.2/lib,~/.rvm/gems/ruby-1.9.3-p327@lascar/gems/rack-test-0.6.2/lib,~/.r
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
setlocal nosmartindent
setlocal softtabstop=2
setlocal nospell
setlocal spellcapcheck=[.?!]\\_[\\])'\"\	\ ]\\+
setlocal spellfile=
setlocal spelllang=en
setlocal statusline=
setlocal suffixesadd=.rb
setlocal swapfile
setlocal synmaxcol=3000
if &syntax != 'haml'
setlocal syntax=haml
endif
setlocal tabstop=2
setlocal tags=~/lascar/tags,~/lascar/tmp/tags,~/lascar/.git/haml.tags,~/lascar/.git/tags,./tags,./TAGS,tags,TAGS
setlocal textwidth=0
setlocal thesaurus=
setlocal undofile
setlocal nowinfixheight
setlocal nowinfixwidth
setlocal wrap
setlocal wrapmargin=0
silent! normal! zE
let s:l = 14 - ((13 * winheight(0) + 25) / 50)
if s:l < 1 | let s:l = 1 | endif
exe s:l
normal! zt
14
normal! 010l
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
