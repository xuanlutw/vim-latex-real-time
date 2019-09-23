" Vim Latex Real Time
" Lu Chia-Hsuan, 2019.05.11

" Load only once
if exists("g:loaded_vim_latex_real_time")
    finish
endif
let g:loaded_vim_latex_real_time = 1


fun! s:run_backround()

python3 << EOF
import time, vim, os, subprocess
import _thread as thread # Py3

# TODO extract the constant into vim script
sleep_time = 5
comp_time  = 5

def autoread_loop():
    while True:
        # Time... 
        time.sleep(sleep_time)
        
        # Write tmp file
        buff = vim.current.buffer
        tmp_file = open(tmp_name, 'w+')
        for i in range(0, len(buff)):
            tmp_file.write(buff[i] + '\n')
        tmp_file.close()
        
        # Try compile
        p = subprocess.Popen(["xelatex", "-interaction", "nonstopmode", "-output-directory", tmp_path, tmp_name], stdout=FNULL, stderr=subprocess.STDOUT)
        try:
            p.wait(comp_time)
        except:
            p.kill()

# Filenames
extension = vim.eval("expand('%:e')")
full_path = vim.eval("expand('%:p')")

if (extension == "tex"):
    FNULL = open(os.devnull, 'w')
    tmp_path = os.popen('mktemp -d').read()
    tmp_path = tmp_path[0:-1]
    tmp_name = tmp_path + '/a.tex'
    tmp_file = open(tmp_name, 'w+')
    tmp_file.write("\\documentclass[11pt, a4paper]{article}\\begin{document}hello,world\\end{document}")
    tmp_file.close()
    os.system("xelatex -interaction=nonstopmode -output-directory=" + tmp_path + " " + tmp_name + " >/dev/null 2>&1")
    os.system("evince " + tmp_path + "/a.pdf >/dev/null 2>&1 &")
    thread.start_new_thread(autoread_loop, ())

EOF
endfun

call s:run_backround()
