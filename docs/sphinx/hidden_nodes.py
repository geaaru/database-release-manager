"""Simple, inelegant Sphinx extension which adds a directive for a
highlighted code-block that may be toggled hidden and shown in HTML.  
This is possibly useful for teaching courses.
The directive, like the standard code-block directive, takes
a language argument and an optional linenos parameter.  The
hidden-code-block adds starthidden and label as optional 
parameters.
Examples:
.. hidden-code-block:: python
    :starthidden: False
    a = 10
    b = a + 5
.. hidden-code-block:: python
    :label: --- SHOW/HIDE ---
    x = 10
    y = x + 5
Thanks to http://www.javascriptkit.com/javatutors/dom3.shtml for 
inspiration on the javascript.  
Thanks to Milad 'animal' Fatenejad for suggesting this extension 
in the first place.
Written by Anthony 'el Scopz' Scopatz, January 2012.
Released under the WTFPL (http://sam.zoy.org/wtfpl/).
"""

import codecs

from docutils import nodes
from docutils.parsers.rst import directives

from sphinx.directives.code import CodeBlock, LiteralInclude
from sphinx.util.nodes import set_source_info

HCB_COUNTER = 0

js_showhide = """\
<script type="text/javascript">
    function showhide(element){
        if (!document.getElementById)
            return
        if (element.style.display == "block")
            element.style.display = "none"
        else
            element.style.display = "block"
    };
</script>
"""

def nice_bool(arg):
    tvalues = ('true',  't', 'yes', 'y')
    fvalues = ('false', 'f', 'no',  'n')
    arg = directives.choice(arg, tvalues + fvalues)
    return arg in tvalues


class hidden_code_block(nodes.General, nodes.FixedTextElement):
    pass


class HiddenCodeBlock(CodeBlock):
    """Hidden code block is Hidden"""

    option_spec = dict(starthidden=nice_bool, 
                       label=str,
                       **CodeBlock.option_spec)

    def run(self):
        # Body of the method is more or less copied from CodeBlock
        code = u'\n'.join(self.content)
        hcb = hidden_code_block(code, code)
        hcb['language'] = self.arguments[0]
        hcb['linenos'] = 'linenos' in self.options
        hcb['starthidden'] = self.options.get('starthidden', False)
        hcb['label'] = self.options.get('label', '+ show/hide code')
        hcb.line = self.lineno
        return [hcb]

class HiddenLiteralInclude(LiteralInclude):
    """Hidden code block is Hidden"""

    option_spec = dict(starthidden=nice_bool, 
                       label=str,
                       **LiteralInclude.option_spec)

    def run(self):
        # Body of the method is more or less copied from LiteralInclude
        document = self.state.document
        if not document.settings.file_insertion_enabled:
            return [document.reporter.warning('File insertion disabled',
                                              line=self.lineno)]
        env = document.settings.env
        rel_filename, filename = env.relfn2path(self.arguments[0])

        if 'pyobject' in self.options and 'lines' in self.options:
            return [document.reporter.warning(
                'Cannot use both "pyobject" and "lines" options',
                line=self.lineno)]

        encoding = self.options.get('encoding', env.config.source_encoding)
        codec_info = codecs.lookup(encoding)
        try:
            f = codecs.StreamReaderWriter(open(filename, 'rb'),
                    codec_info[2], codec_info[3], 'strict')
            lines = f.readlines()
            f.close()
        except (IOError, OSError):
            return [document.reporter.warning(
                'Include file %r not found or reading it failed' % filename,
                line=self.lineno)]
        except UnicodeError:
            return [document.reporter.warning(
                'Encoding %r used for reading included file %r seems to '
                'be wrong, try giving an :encoding: option' %
                (encoding, filename))]

        objectname = self.options.get('pyobject')
        if objectname is not None:
            from sphinx.pycode import ModuleAnalyzer
            analyzer = ModuleAnalyzer.for_file(filename, '')
            tags = analyzer.find_tags()
            if objectname not in tags:
                return [document.reporter.warning(
                    'Object named %r not found in include file %r' %
                    (objectname, filename), line=self.lineno)]
            else:
                lines = lines[tags[objectname][1]-1 : tags[objectname][2]-1]

        linespec = self.options.get('lines')
        if linespec is not None:
            try:
                linelist = parselinenos(linespec, len(lines))
            except ValueError as err:
                return [document.reporter.warning(str(err), line=self.lineno)]
            # just ignore nonexisting lines
            nlines = len(lines)
            lines = [lines[i] for i in linelist if i < nlines]
            if not lines:
                return [document.reporter.warning(
                    'Line spec %r: no lines pulled from include file %r' %
                    (linespec, filename), line=self.lineno)]

        linespec = self.options.get('emphasize-lines')
        if linespec:
            try:
                hl_lines = [x+1 for x in parselinenos(linespec, len(lines))]
            except ValueError as err:
                return [document.reporter.warning(str(err), line=self.lineno)]
        else:
            hl_lines = None

        startafter = self.options.get('start-after')
        endbefore  = self.options.get('end-before')
        prepend    = self.options.get('prepend')
        append     = self.options.get('append')
        if startafter is not None or endbefore is not None:
            use = not startafter
            res = []
            for line in lines:
                if not use and startafter and startafter in line:
                    use = True
                elif use and endbefore and endbefore in line:
                    use = False
                    break
                elif use:
                    res.append(line)
            lines = res

        if prepend:
           lines.insert(0, prepend + '\n')
        if append:
           lines.append(append + '\n')

        text = ''.join(lines)
        if self.options.get('tab-width'):
            text = text.expandtabs(self.options['tab-width'])
        retnode = hidden_code_block(text, text, source=filename)
        set_source_info(self, retnode)
        if self.options.get('language', ''):
            retnode['language'] = self.options['language']
        if 'linenos' in self.options:
            retnode['linenos'] = True
        if hl_lines is not None:
            retnode['highlight_args'] = {'hl_lines': hl_lines}
        retnode['starthidden'] = self.options.get('starthidden', False)
        retnode['label'] = self.options.get('label', '+ show/hide contents')
        env.note_dependency(rel_filename)
        return [retnode]

def visit_hcb_html(self, node):
    """Visit hidden code block"""
    global HCB_COUNTER
    HCB_COUNTER += 1

    # We want to use the original highlighter so that we don't
    # have to reimplement it.  However it raises a SkipNode 
    # error at the end of the function call.  Thus we intercept
    # it and raise it again later.
    try: 
        self.visit_literal_block(node)
    except nodes.SkipNode:
        pass

    # The last element of the body should be the literal code 
    # block that was just made.
    code_block = self.body[-1]

    fill_header = {'divname': 'hiddencodeblock{}'.format(HCB_COUNTER), 
                   'startdisplay': 'none' if node['starthidden'] else 'block', 
                   'label': node.get('label'), 
                   }

    divheader = ("""<a href="javascript:showhide(document.getElementById('{divname}'))">"""
                 """{label}</a><br />"""
                 '''<div id="{divname}" style="display: {startdisplay}">'''
                 ).format(**fill_header)

    code_block = js_showhide + divheader + code_block + "</div>"

    # reassign and exit
    self.body[-1] = code_block
    raise nodes.SkipNode


def depart_hcb_html(self, node):
    """Depart hidden code block"""
    # Stub because of SkipNode in visit


def setup(app):
    app.add_directive('hidden-code-block', HiddenCodeBlock)
    app.add_directive('hidden-literalinclude', HiddenLiteralInclude)
    app.add_node(hidden_code_block, html=(visit_hcb_html, depart_hcb_html))
    
