FROM centos:centos7

MAINTAINER Paul Redmond <paulrredmond@gmail.com>

# Install packages
RUN yum install -y epel-release \
    && yum install -y nodejs git-core zlib zlib-devel gcc-c++ patch readline readline-devel libyaml-devel libffi-devel openssl-devel make bzip2 autoconf automake libtool bison curl sqlite-devel mysql-devel postgresql-client sudo \
    && yum clean all \
    && echo 'eval "$(rbenv init -)"' >> /etc/profile.d/rbenv.sh \
    && chmod +x /etc/profile.d/rbenv.sh \
    && useradd -m rails

USER rails

# rbenv
RUN git clone https://github.com/sstephenson/rbenv.git ~/.rbenv \
	&& git clone https://github.com/sstephenson/ruby-build.git ~/.rbenv/plugins/ruby-build

ENV PATH ~/.rbenv/bin:~/.rbenv/shims:$PATH
ENV CONFIGURE_OPTS --disable-install-doc
RUN rbenv install 2.2.0 \
    && rbenv global 2.2.0

# Install bundler
RUN echo 'gem: --no-rdoc --no-ri' >> ~/.gemrc \
    && gem install bundler \
    && bundle config --global frozen 1 \
    && mkdir -p /home/rails/app

WORKDIR /home/rails/app

ONBUILD COPY ./Gemfile /home/rails/app/
ONBUILD COPY ./Gemfile.lock /home/rails/app/
ONBUILD RUN bundle install
ONBUILD COPY . /home/rails/app

EXPOSE 3000
CMD ["rails", "server", "-b", "0.0.0.0"]