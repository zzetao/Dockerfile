FROM ubuntu:14.04

MAINTAINER zzetao <izzetao@gmail.com>

RUN cp /etc/apt/sources.list /etc/apt/sources.list.bak
#RUN sed -i s:/archive.ubuntu.com:/mirrors.aliyun.com/ubuntu:g /etc/apt/sources.list
RUN sed -i s:/archive.ubuntu.com:/mirrors.tuna.tsinghua.edu.cn/ubuntu:g /etc/apt/sources.list
RUN cat /etc/apt/sources.list
RUN apt-get clean

RUN apt-get -y update --fix-missing && apt-get -y install \
    curl \
    bash \ 
    wget \
    zsh \
    git \
    mysql-server-5.6 \
    nginx \
    ruby-sass

#=== oh-my-zsh
RUN wget https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh -O - | zsh || true && chsh -s /bin/zsh

#=== zsh theme
COPY elissa.zsh-theme /root/.oh-my-zsh/themes/

RUN sed -i -- 's/ZSH_THEME="robbyrussell"/ZSH_THEME="elissa"/' ~/.zshrc

#=== zsh plugins
RUN git clone git://github.com/zsh-users/zsh-autosuggestions $ZSH_CUSTOM/plugins/zsh-autosuggestions

RUN sed -i -- 's/plugins=(git)/plugins=(git extract zsh-autosuggestions sublime npm brew z)/' ~/.zshrc

#=== node
RUN curl -sL https://deb.nodesource.com/setup_7.x | sudo -E bash -

RUN apt-get -y install \
    nodejs

RUN npm i -g gulp webpack yarn cnpm --registry=https://registry.npm.taobao.org 

#=== vim
# YouCompleteMe
RUN apt-get update && apt-get install -y software-properties-common python-software-properties && add-apt-repository ppa:jonathonf/vim

RUN apt-get upgrade && apt-get install -y vim build-essential cmake python-dev python3-dev

RUN git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim

COPY .vimrc /root/ 

COPY molokai.vim /root/.vim/colors/

RUN vim +BundleInstall +qall

RUN cd ~/.vim/bundle/YouCompleteMe && ./install.py --tern-completer

#=== docker

EXPOSE 80 443

WORKDIR /root

CMD ["zsh"]


# Cleanup
RUN apt-get clean -q
RUN rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
