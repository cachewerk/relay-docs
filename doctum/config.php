<?php

use Doctum\Doctum;
use Doctum\Version\Version;
use Doctum\Version\VersionCollection;

use Symfony\Component\Finder\Finder;

$root = realpath(__DIR__ . '/..');
$src = __DIR__ . '/.source';
$stubs = __DIR__ . '/.stubs';

if (! is_dir($src)) {
    mkdir($src);
}

$versions = new class ($src, $stubs) extends VersionCollection {
    public function __construct(private string $src, private string $stubs)
    {
    }

    protected function switchVersion(Version $version)
    {
        copy(
            "{$this->stubs}/{$version->getName()}/relay.stub.php",
            "{$this->src}/relay.stub.php",
        );
    }
};

$latest = trim(file_get_contents("{$stubs}/LATEST"));

$iterator = Finder::create()
    ->files()
    ->name('*.stub.php')
    ->in($src);

return new Doctum($iterator, [
    'title' => 'Relay API',
    'theme' => 'relay',
    'source_dir' => $src,
    'build_dir' => "{$root}/dist/api/%version%",
    'cache_dir' => __DIR__ . "/.cache/%version%",
    'template_dirs' => [__DIR__ . '/theme'],
    'base_url' => 'https://docs.relay.so/api',
    'versions' => $versions
        ->add('0.x')
        ->add('develop'),
]);
