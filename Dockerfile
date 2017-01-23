FROM rollout/base:latest
RUN mkdir /Dsymprocessor
COPY . /Dsymprocessor
CMD cd /Dsymprocessor && npm install && DEBUG=myapp:* npm start
