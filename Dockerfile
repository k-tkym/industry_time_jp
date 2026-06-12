FROM ruby:3.3-slim

RUN apt-get update -qq && apt-get install -y build-essential git tzdata \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

RUN gem install bundler

# 依存関係のインストールをキャッシュさせるためのCOPY
COPY industry_time.gemspec Gemfile Gemfile.lock ./
COPY lib/industry_time/version.rb ./lib/industry_time/

RUN bundle install

COPY . .

CMD ["bash"]
