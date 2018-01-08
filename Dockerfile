FROM ruby:2.4-alpine3.7

# Install dependencies
RUN apk update && apk upgrade && \
    apk add --no-cache bash git openssh build-base nodejs tzdata
    
# Configure the main working directory. This is the base 
# directory used in any further RUN, COPY, and ENTRYPOINT 
# commands.
RUN mkdir -p /app 
WORKDIR /app

# Copy the Gemfile as well as the Gemfile.lock and install 
# the RubyGems. This is a separate step so the dependencies 
# will be cached unless changes to one of those two files 
# are made.
COPY Gemfile Gemfile.lock ./ 
RUN gem install bundler && bundle install --jobs 20 --retry 5

# Copy the main application.
COPY . ./

RUN rails assets:precompile

# Expose port 3000 to the Docker host, so we can access it 
# from other docker containers.
EXPOSE 3000

CMD ["bundle", "exec", "rake", "resque:work", "QUEUE=*", "&", "bundle", "exec", "rails", "server", "-b", "0.0.0.0"]
