#!perl

my $blog_url = undef;
my $feed_url = undef;
my $time_zone = undef;
my $generator = undef;
my $author = undef;

use v5.12;
use HTTP::Tiny;
use List::Util qw/uniq max/;
use DateTime;
use XML::Feed;

die unless defined $blog_url;
$feed_url //= $blog_url;
$time_zone //= 'Asia/Shanghai';
$generator //= 'jyi2ya magic rss generator';
($author) = ($author // $blog_url =~ m{https://www\.cnblogs\.com/([^/]*)/});

my $http = HTTP::Tiny->new;

# atom 格式：https://validator.w3.org/feed/docs/atom.html

$_ = $http->get($blog_url)->{content};
my $feed = XML::Feed->new('Atom');

# <id> 频道的一个标识，可以随便写
$feed->id($blog_url);

# <title> 频道名称
my ($title) = m{<title>(.*?) - 博客园</title>};
$feed->title($title);

# <updated> 修改日期，匹配最后一篇发布的文章的发布日期
m{posted @ ([^-]*?)-([^-]*?)-([^-]*?) ([^:]*?):(.*)};
$feed->modified(
	DateTime->new(
		year => $1,
		month => $2,
		day => $3,
		hour => $4,
		minute => $5,
		second => 0,
		nanosecond => 0,
		time_zone => $time_zone
	)
);

# 与频道关联的站点 url
$feed->link($blog_url);

# 频道描述
my ($desc) = m{<p id="tagline">(.*?)</p>};
$feed->description($desc);

# 频道语言
$feed->language('zh-cn');

# 版权说明
my ($copyright) = m{(Copyright &copy; .*)};
$feed->copyright($copyright);

# 生成 rss 的程序的名字
$feed->generator($generator);

# 链接到 rss 自己的网址
$feed->self_link($feed_url);

my @urls = uniq sort { $b cmp $a } m{https://www.cnblogs.com/jyi2ya/p/[0-9]+.html}sg;
for my $url (@urls) {
	$_ = $http->get($url)->{content};
	my $entry = XML::Feed::Entry->new();

	# 文章的 id，这里可以直接用 url
	$entry->id($url);

	# 文章标题
	my ($title) = m{<title>(.*?) - jyi2ya - 博客园</title>};
	$entry->title($title);

	# 文章 url
	$entry->link($url);

	# 大概是摘要……
	my ($desc) = m{<meta name="description" content="([^"]*)" />};
	$entry->summary($desc);

	# 文章内容
	my ($content) = m{<div id="cnblogs_post_body" class="blogpost-body cnblogs-markdown">(.*?)</div>}s;
	$entry->content($content);

	# 文章作者
	$entry->author($author);

	# 文章分类 FIXME: 不知道怎么得到文章分类
	$entry->category('note');

	m{<span id="post-date">([^-]*?)-([^-]*?)-([^-]*?) ([^:]*?):(.*)</span>};
	my $date = DateTime->new(
		year => $1,
		month => $2,
		day => $3,
		hour => $4,
		minute => $5,
		second => 0,
		nanosecond => 0,
		time_zone => $time_zone
	);

       	# 发布时间
	$entry->issued($date);

	# 修改时间
	$entry->modified($date);

	$feed->add_entry($entry);
}

print $feed->as_xml;
