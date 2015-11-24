FROM ruby:2.2.3-onbuild

EXPOSE 80

CMD ["bundle", "exec", "ruby", "app.rb"]