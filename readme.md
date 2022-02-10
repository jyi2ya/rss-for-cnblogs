可以为博客园的博客生成 rss

## 依赖

+ 5.12 或更高版本的 perl 解释器
+ HTTP::Tiny（也许 Perl 发行版自带了）
+ List::Util（也许 Perl 发行版自带了）
+ DateTime
+ XML::Feed

## 使用说明：

### 1. 修改代码

把 3-7 行的变量改掉：

```perl
my $blog_url = undef;
my $feed_url = undef;
my $time_zone = undef;
my $generator = undef;
my $author = undef;
```

他们的意思分别是：

+ `$blog_url`：博客的 url
+ `$feed_url`：如果要把生成的东西放到网上让人订阅，这个就是 feed.xml 的 url
+ `$time_zone`：博客使用的时区，默认是 `Asia/Shanghai`
+ `$generator`：rss 生成器的名字，默认是 `jyi2ya magic rss generator`
+ `$author`：作者名字。默认会从 `$blog_url` 里找出用户名

其中，只有 `$blog_url` 是必须要改的，其他可以保持 `undef`。软件会试图把没填的部分填上。

这是一个合理的改法：

```perl
my $blog_url = 'https://www.cnblogs.com/jyi2ya';
my $feed_url = undef;
my $time_zone = undef;
my $generator = undef;
my $author = undef;
```

这是一个比较完整的设置：

```perl
my $blog_url = 'https://www.cnblogs.com/jyi2ya/';
my $feed_url = 'https://orz.sto.org/superfeed';
my $time_zone = 'Asia/Shanghai';
my $generator = 'jyi2ya magic rss generator';
my $author = 'jyi';
```

### 2. 运行

使用 `perl generate.pl`，程序会把生成的 rss 输出到标准输出。
