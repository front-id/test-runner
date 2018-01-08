FROM alvar0hurtad0/test-runner

# Install stuff to run javascript tests.
RUN apt-get -qq -y install iceweasel > /dev/null \
    && apt-get install xvfb -y \
    && apt-get install openjdk-7-jre-headless -y \
    && Xvfb :99 -ac  \
    && export DISPLAY=:99

RUN wget http://selenium-release.storage.googleapis.com/2.53/selenium-server-standalone-2.53.0.jar \
    &&java -jar selenium-server-standalone-2.53.0.jar > /dev/null 2>&1 &

