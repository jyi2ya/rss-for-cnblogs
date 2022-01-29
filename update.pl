#!perl

use v5.12;
use HTTP::Tiny;
use List::Util qw/uniq max/;
use DateTime;
use XML::Feed;

open STDOUT, '>', 'feed.xml';

my $feed = XML::Feed->new('RSS');

$feed->id("http://".time.rand()."/"); # 魔法……不知道是什么
$feed->title('jyi2ya 的博客'); # 频道名称
$feed->link('https://cnblogs.com/jyi2ya'); # 与频道关联的站点 url
$feed->description('记录一些奇奇怪怪的东西'); # 频道描述
$feed->language('zh-cn'); #频道语言
$feed->copyright('© 2022 jyi2ya'); # 版权说明 TODO:年份改成自动的
$feed->generator('jyi2ya magic rss generator'); # 生成 rss 的程序的名字
$feed->self_link('http://orz.sto'); # 链接到 rss 自己的网址 TODO 改这个
$feed->modified(DateTime->now); # 修改日期

my $http = HTTP::Tiny->new;

$_ = $http->get('https://www.cnblogs.com/jyi2ya/')->{content};
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
	$entry->issued(DateTime->now); # 发布时间
	$entry->modified(DateTime->now); # 修改时间

	$feed->add_entry($entry);
}

say $feed->as_xml;
