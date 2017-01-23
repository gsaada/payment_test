FROM rollout/base:latest
RUN mkdir /Dsymprocessor
COPY . /Dsymprocessor
CMD cd /Dsymprocessor && npm install && npm start
