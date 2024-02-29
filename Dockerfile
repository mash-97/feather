FROM ruby:3.0

WORKDIR /usr/src/app

RUN gem install sinatra rackup

COPY . .

EXPOSE 8080

CMD ["ruby", "./app.rb"]


