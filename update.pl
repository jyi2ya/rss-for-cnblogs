#!perl

use v5.12;
use HTTP::Tiny;
use List::Util qw/uniq max/;
use DateTime;
use XML::Feed;

my $blog_url = 'https://www.cnblogs.com/jyi2ya/';
my $feed_url = '';
my $time_zone = 'Asia/Shanghai';

my $feed = XML::Feed->new('Atom');
my $http = HTTP::Tiny->new;

$_ = $http->get($blog_url)->{content};

$feed->id("http://".time.rand()."/"); # 魔法……不知道是什么

my ($title) = m{<title>(.*?) - 博客园</title>};
$feed->title($title); # 频道名称

$feed->link($blog_url); # 与频道关联的站点 url

my ($desc) = m{<p id="tagline">(.*?)</p>};
$feed->description($desc); # 频道描述

$feed->language('zh-cn'); # 频道语言

my ($copyright) = m{(Copyright &copy; .*)};
$feed->copyright($copyright); # 版权说明

$feed->generator('jyi2ya magic rss generator'); # 生成 rss 的程序的名字

$feed->self_link('http://orz.sto'); # 链接到 rss 自己的网址 TODO 改这个

m{posted @ ([^-]*?)-([^-]*?)-([^-]*?) ([^:]*?):(.*)};
# 修改日期
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

my @urls = uniq sort { $b cmp $a } m{https://www.cnblogs.com/jyi2ya/p/[0-9]+.html}sg;
for my $url (@urls) {
	$_ = $http->get($url)->{content};
	my $entry = XML::Feed::Entry->new();

	$entry->id("http://".time.rand()."/"); # 同样是魔法

	my ($title) = m{<title>(.*?) - jyi2ya - 博客园</title>};
	$entry->title($title); # 文章标题

	$entry->link($url); # 文章 url

	my ($desc) = m{<meta name="description" content="([^"]*)" />};
	$entry->summary($desc); # 大概是摘要……

	my ($content) = m{<div id="cnblogs_post_body" class="blogpost-body cnblogs-markdown">(.*?)</div>}s;
	$entry->content($content); # 文章内容

	$entry->author('jyi2ya'); # 文章作者

	$entry->category('note'); # 文章分类 TODO: 改这些

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
	$entry->issued($date); # 发布时间
	$entry->modified($date); # 修改时间

	$feed->add_entry($entry);
}

print $feed->as_xml;
