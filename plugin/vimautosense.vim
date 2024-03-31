"=============================================================================
" Copyright (c) 2024-Now Qeuroal
"
"=============================================================================
"{{{> LOAD GUARD
if exists('g:loaded_vas')
	finish
elseif v:version < 702
	echoerr 'AutoComplPop does not support this version of vim (' . v:version . ').'
	finish
endif
let g:loaded_vas = 1
"<}}}

"=============================================================================
"{{{> FUNCTION

"
function s:defineOption(name, default)
	if !exists(a:name)
		let {a:name} = a:default
	endif
endfunction

"
function s:makeDefaultBehavior()
	let behavs = {
				\   '*'      : [],
				\   'ruby'   : [],
				\   'python' : [],
				\   'xml'    : [],
				\   'html'   : [],
				\   'xhtml'  : [],
				\   'css'    : [],
				\ }
	"---------------------------------------------------------------------------
	if !empty(g:vas_behaviorUserDefinedFunction)
		for key in keys(behavs)
			call add(behavs[key], {
						\   'command'      : "\<C-x>\<C-u>",
						\   'completefunc' : g:vas_behaviorUserDefinedFunction,
						\   'pattern'      : g:vas_behaviorUserDefinedPattern,
						\   'repeat'       : 0,
						\ })
		endfor
	endif
	"---------------------------------------------------------------------------
	if g:vas_behaviorSnipmateLength >= 0
		for key in keys(behavs)
			call add(behavs[key], {
						\   'command'      : "\<C-x>\<C-u>",
						\   'completefunc' : 'vas#completeSnipmate',
						\   'pattern'      : printf('\(^\|\s\|\<\)\u\{%d,}$', g:vas_behaviorSnipmateLength),
						\   'repeat'       : 0,
						\   'onPopupClose' : 'vas#onPopupCloseSnipmate'
						\ })
		endfor
	endif
	"---------------------------------------------------------------------------
	if g:vas_behaviorKeywordLength >= 0
		for key in keys(behavs)
			call add(behavs[key], {
						\   'command' : g:vas_behaviorKeywordCommand,
						\   'pattern' : printf('\k\{%d,}$', g:vas_behaviorKeywordLength),
						\   'repeat'  : 0,
						\ })
		endfor
	endif
	"---------------------------------------------------------------------------
	if g:vas_behaviorFileLength >= 0
		for key in keys(behavs)
			call add(behavs[key], {
						\   'command' : "\<C-x>\<C-f>",
						\   'pattern' : printf('\f[%s]\f\{%d,}$', (has('win32') || has('win64') ? '/\\' : '/'),
						\                      g:vas_behaviorFileLength),
						\   'exclude' : '[*/\\][/\\]\f*$\|[^[:print:]]\f*$',
						\   'repeat'  : 1,
						\ })
		endfor
	endif
	"---------------------------------------------------------------------------
	if has('ruby') && g:vas_behaviorRubyOmniMethodLength >= 0
		call add(behavs.ruby, {
					\   'command' : "\<C-x>\<C-o>",
					\   'pattern' : printf('[^. \t]\(\.\|::\)\k\{%d,}$',
					\                      g:vas_behaviorRubyOmniMethodLength),
					\   'repeat'  : 0,
					\ })
	endif
	"---------------------------------------------------------------------------
	if has('ruby') && g:vas_behaviorRubyOmniSymbolLength >= 0
		call add(behavs.ruby, {
					\   'command' : "\<C-x>\<C-o>",
					\   'pattern' : printf('\(^\|[^:]\):\k\{%d,}$',
					\                      g:vas_behaviorRubyOmniSymbolLength),
					\   'repeat'  : 0,
					\ })
	endif
	"---------------------------------------------------------------------------
	if has('python') && g:vas_behaviorPythonOmniLength >= 0
		call add(behavs.python, {
					\   'command' : "\<C-x>\<C-o>",
					\   'pattern' : printf('\k\.\k\{%d,}$',
					\                      g:vas_behaviorPythonOmniLength),
					\   'repeat'  : 0,
					\ })
	endif
	"---------------------------------------------------------------------------
	if g:vas_behaviorXmlOmniLength >= 0
		call add(behavs.xml, {
					\   'command' : "\<C-x>\<C-o>",
					\   'pattern' : printf('\(<\|<\/\|<[^>]\+ \|<[^>]\+=\"\)\k\{%d,}$',
					\                      g:vas_behaviorXmlOmniLength),
					\   'repeat'  : 0,
					\ })
	endif
	"---------------------------------------------------------------------------
	if g:vas_behaviorHtmlOmniLength >= 0
		let behavHtml = {
					\   'command' : "\<C-x>\<C-o>",
					\   'pattern' : printf('\(<\|<\/\|<[^>]\+ \|<[^>]\+=\"\)\k\{%d,}$',
					\                      g:vas_behaviorHtmlOmniLength),
					\   'repeat'  : 1,
					\ }
		call add(behavs.html , behavHtml)
		call add(behavs.xhtml, behavHtml)
	endif
	"---------------------------------------------------------------------------
	if g:vas_behaviorCssOmniPropertyLength >= 0
		call add(behavs.css, {
					\   'command' : "\<C-x>\<C-o>",
					\   'pattern' : printf('\(^\s\|[;{]\)\s*\k\{%d,}$',
					\                      g:vas_behaviorCssOmniPropertyLength),
					\   'repeat'  : 0,
					\ })
	endif
	"---------------------------------------------------------------------------
	if g:vas_behaviorCssOmniValueLength >= 0
		call add(behavs.css, {
					\   'command' : "\<C-x>\<C-o>",
					\   'pattern' : printf('[:@!]\s*\k\{%d,}$',
					\                      g:vas_behaviorCssOmniValueLength),
					\   'repeat'  : 0,
					\ })
	endif
	"---------------------------------------------------------------------------
	return behavs
endfunction
"<}}}

"=============================================================================
"{{{> INITIALIZATION

"-----------------------------------------------------------------------------
call s:defineOption('g:vas_enableAtStartup', 1)
call s:defineOption('g:vas_mappingDriven', 0)
call s:defineOption('g:vas_ignorecaseOption', 1)
call s:defineOption('g:vas_completeOption', '.,w,b,k')
call s:defineOption('g:vas_completeoptPreview', 0)
call s:defineOption('g:vas_behaviorUserDefinedFunction', '')
call s:defineOption('g:vas_behaviorUserDefinedPattern' , '\k$')
call s:defineOption('g:vas_behaviorSnipmateLength', -1)
call s:defineOption('g:vas_behaviorKeywordCommand', "\<C-n>")
call s:defineOption('g:vas_behaviorKeywordLength', 2)
call s:defineOption('g:vas_behaviorFileLength', 0)
call s:defineOption('g:vas_behaviorRubyOmniMethodLength', 0)
call s:defineOption('g:vas_behaviorRubyOmniSymbolLength', 1)
call s:defineOption('g:vas_behaviorPythonOmniLength', 0)
call s:defineOption('g:vas_behaviorXmlOmniLength', 0)
call s:defineOption('g:vas_behaviorHtmlOmniLength', 0)
call s:defineOption('g:vas_behaviorCssOmniPropertyLength', 1)
call s:defineOption('g:vas_behaviorCssOmniValueLength', 0)
call s:defineOption('g:vas_behavior', {})
"-----------------------------------------------------------------------------
call extend(g:vas_behavior, s:makeDefaultBehavior(), 'keep')
"-----------------------------------------------------------------------------
command! -bar -narg=0 VasEnable  call vas#enable()
command! -bar -narg=0 VasDisable call vas#disable()
command! -bar -narg=0 VasLock    call vas#lock()
command! -bar -narg=0 VasUnlock  call vas#unlock()
"-----------------------------------------------------------------------------
" legacy commands
command! -bar -narg=0 AutoComplPopEnable  VasEnable
command! -bar -narg=0 AutoComplPopDisable VasDisable
command! -bar -narg=0 AutoComplPopLock    VasLock
command! -bar -narg=0 AutoComplPopUnlock  VasUnlock
"-----------------------------------------------------------------------------
if g:vas_enableAtStartup
	VasEnable
endif
"-----------------------------------------------------------------------------
"<}}}

