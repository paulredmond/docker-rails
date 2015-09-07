FROM centos:centos7

MAINTAINER Paul Redmond <paulrredmond@gmail.com>

# Install packages
RUN yum install -y epel-release \
    && yum install -y nodejs git-core zlib zlib-devel gcc-c++ patch readline readline-devel libyaml-devel libffi-devel openssl-devel make bzip2 autoconf automake libtool bison curl sqlite-devel mysql-devel postgresql-client \
    && yum clean all

# rbenv
RUN git clone https://github.com/sstephenson/rbenv.git /root/.rbenv \
	&& git clone https://github.com/sstephenson/ruby-build.git /root/.rbenv/plugins/ruby-build \
	&& /root/.rbenv/plugins/ruby-build/install.sh

ENV PATH /root/.rbenv/bin:/root/.rbenv/shims:$PATH
RUN echo 'eval "$(rbenv init -)"' >> /etc/profile.d/rbenv.sh \
    && chmod u+x /etc/profile.d/rbenv.sh \
    && echo 'eval "$(rbenv init -)"' >> ~/.bash_profile
ENV CONFIGURE_OPTS --disable-install-doc
RUN rbenv install 2.2.0 && rbenv global 2.2.0

# Install bundler
RUN echo 'gem: --no-rdoc --no-ri' >> /.gemrc
RUN gem install bundler

# Application
RUN bundle config --global frozen 1
RUN mkdir /app
WORKDIR /app

ONBUILD COPY ./Gemfile /app/
ONBUILD COPY ./Gemfile.lock /app/
ONBUILD RUN bundle install
ONBUILD COPY . /app

EXPOSE 3000
CMD ["rails", "server", "-b", "0.0.0.0"]