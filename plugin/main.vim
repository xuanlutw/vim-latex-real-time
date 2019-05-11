" Vim Latex Real Time
" Lu Chia-Hsuan, 2019.05.11

" Load only once
if exists("g:loaded_vim_latex_real_time")
    finish
endif
let g:loaded_vim_latex_real_time = 1


fun! s:run_backround()

python3 << EOF
import time, vim, os
import _thread as thread # Py3
from tempfile import TemporaryDirectory

# TODO extract the constant into vim script
sleep_time = 5
comp_time  = 2

def autoread_loop():
    while True:
        # Time... 
        time.sleep(sleep_time)
        # Write tmp file
        buff = vim.current.buffer
        tmp_file = open(tex_name, 'w+')
        for i in range(0, len(buff)):
            tmp_file.write(buff[i] + '\n')
        tmp_file.close()
        # Try compile
        FNULL = open(os.devnull, 'w')
        p = subprocess.Popen(["xelatex", "-output-directory", file_path, tex_name], stdout=FNULL, stderr=subprocess.STDOUT)
        try:
            p.wait(1)
        except:
            p.kill()

# Filenames
extension = vim.eval("expand('%:e')")
file_path = vim.eval("expand('%:p:h')") + "/.texlive/"
file_name = file_path + vim.eval("expand('%:t:r')")
pdf_name = file_name + ".pdf"
ps_name  = file_name + ".ps"
tex_name = file_name + ".tex"

# Init files
os.system("mkdir "  + file_path + " > /dev/null 2>&1")
os.system("touch "  + ps_name + " > /dev/null 2>&1") 
os.system("ps2pdf " + ps_name + " " + pdf_name + " > /dev/null 2>&1") 
os.system("touch "  + tex_name)
os.system("evince " + pdf_name + " &")

# Startup
thread.start_new_thread(autoread_loop, ())
EOF
endfun

call s:run_backround()
