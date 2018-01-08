FROM alvar0hurtad0/test-runner

# Install stuff to run javascript tests.
RUN apt-get -y install iceweasel \
  xvfb \
  gtk2-engines-pixbuf \
  xfonts-cyrillic \
  xfonts-100dpi \
  xfonts-75dpi \
  xfonts-base \
  xfonts-scalable
RUN Xvfb :10 -ac -screen 0 1024x768x8 &
RUN export DISPLAY=:10

RUN curl -J -O -L http://selenium-release.storage.googleapis.com/2.53/selenium-server-standalone-2.53.0.jar
RUN ln -s ./selenium-server-standalone-2.53.0.jar ./selenium-server-standalone.jar
