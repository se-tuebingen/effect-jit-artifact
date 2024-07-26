# JIT

This is a one time collaboration paper repo.

Things you should be aware of:

- I am using Madoko + LaTeX to build the paper.
  It is a special build of Madoko that I maintain, which is customized to work well for conference publications.
  To avoid you having to build Madoko yourselves, I include it as a tarball.
  It is an npm package and should be installed accordingly, so that the `madoko` command is available.
  You can do so by extracting the archive, entering the extracted directory and then running: `npm install && npm link`. Potentially also just `npm install ZIPFILE` could work.
  - The file is `madoko-latex.tgz`

- The file `bibliography.bib` should **not be edited**. It is automatically copied from a central private repository. It already contains tons of references. If you want to add even more, just send them to me. That's easier. Or change the file and tell me :)
  - or just add it to `additional.bib`
