# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project follows phpMyAdmin versioning.

## [4.8.3] - 2018-09-04
### Changed
  - Upgrade phpMyAdmin version to 4.8.3

## [4.8.2] - 2018-07-28
### Changed
  - Upgrade phpMyAdmin version to 4.8.2

## [4.8.1] - 2018-05-26
### Changed
  - Upgrade phpMyAdmin version to 4.8.1

## [4.8.0.1] - 2018-04-23
### Changed
  - Upgrade phpMyAdmin version to 4.8.0.1

## [4.8.0] - 2018-04-09
### Changed
  - Upgrade phpMyAdmin version to 4.8.0

## [4.7.9] - 2018-03-09
### Changed
  - Upgrade phpMyAdmin version to 4.7.9

## [4.7.8] - 2018-02-22
### Changed
  - Upgrade phpMyAdmin version to 4.7.8

## [4.7.7] - 2017-12-28
### Changed
  - Upgrade phpMyAdmin version to 4.7.7

## [4.7.6] - 2017-12-01
### Changed
  - Upgrade phpMyAdmin version to 4.7.6

## [4.7.5] - 2017-10-24
### Changed
  - Upgrade phpMyAdmin version to 4.7.5

## [4.7.4] - 2017-09-03
### Changed
  - Upgrade phpMyAdmin version to 4.7.4

## [4.7.3-1] - 2017-09-03
### Added
  - Opcache config

### Changed
  - Optimise apache config

## [4.7.3] - 2017-07-21
### Changed
  - Upgrade phpMyAdmin version to 4.7.3

## [4.7.2] - 2017-07-19
### Changed
  - Upgrade phpMyAdmin version to 4.7.2
  - Upgrade baseimage to web-baseimage:1.1.0 (debian stretch, php7)
  - Move config.inc.php in config folder

## [4.7.0] - 2017-04-25
### Changed
  - Upgrade phpMyAdmin version to 4.7.0
  - Upgrade baseimage to web-baseimage:1.0.0

## [4.6.6] - 2017-01-24
### Changed
  - Upgrade phpMyAdmin version to 4.6.6

### Fixed
  - Config issue with files in a volume

## [4.6.5] - 2016-11-25
### Changed
  - Upgrade baseimage to web-baseimage:0.1.12
  - Upgrade phpMyAdmin version to 4.6.5

## Versions before following the phpMyAdmin versioning

## [0.3.7] - 2016-09-02
### Changed
  - Upgrade baseimage to web-baseimage:0.1.11
  - Upgrade phpMyAdmin version to 4.6.4

## [0.3.6] - 2016-07-26
### Added
  - PHPMYADMIN_SERVER_PATH environment variable

### Changed
  - Upgrade baseimage to web-baseimage:0.1.1
  - Upgrade phpMyAdmin version to 4.6.3

## [0.3.5] - 2016-02-20
### Changed
  - Upgrade baseimage to web-baseimage:0.1.9
  - Upgrade phpMyAdmin version to 4.5.4.1

## [0.3.4] - 2015-12-16
### Changed
  - Upgrade baseimage to web-baseimage:0.1.7
  - Makefile with build no cache

## [0.3.3] - 2015-11-23
### Changed
  - Upgrade phpMyAdmin version to 4.5.2

## [0.3.2] - 2015-11-20
### Changed
  - Upgrade baseimage to web-baseimage:0.1.6

## [0.3.1] - 2015-11-19
### Added
  - Env variable PHPMYADMIN_CONFIG_ABSOLUTE_URI

### Changed
  - Upgrade baseimage to web-baseimage:0.1.5
  - More simple config.inc.php file

### Removed
  - Listen on http when https is enable

## [0.3.0] - 2015-10-30
### Added
  - Easy mariadb ssl support

### Changed  
  - Upgrade baseimage to web-baseimage:0.1.3

## [0.2.2] - 2015-03-03
### Changed
  - Allow single PHPMYADMIN_DB_HOSTS simply by -e PHPMYADMIN_DB_HOSTS=host instead of -e PHPMYADMIN_DB_HOSTS=['host']

### Fixed
  - Fix bootstrap config

## [0.2.1] - 2015-03-02
### Added
  - New SSL certs directory
  - Bootstrap capabilities

## [0.2.0] - 2015-02-23
No changelog before this release sorry :)

[4.8.2]: https://github.com/osixia/docker-phpMyAdmin/compare/v4.8.1...v4.8.2
[4.8.1]: https://github.com/osixia/docker-phpMyAdmin/compare/v4.8.0...v4.8.1
[4.8.0]: https://github.com/osixia/docker-phpMyAdmin/compare/v4.7.9...v4.8.0
[4.7.9]: https://github.com/osixia/docker-phpMyAdmin/compare/v4.7.8...v4.7.9
[4.7.8]: https://github.com/osixia/docker-phpMyAdmin/compare/v4.7.7...v4.7.8
[4.7.7]: https://github.com/osixia/docker-phpMyAdmin/compare/v4.7.6...v4.7.7
[4.7.6]: https://github.com/osixia/docker-phpMyAdmin/compare/v4.7.5...v4.7.6
[4.7.5]: https://github.com/osixia/docker-phpMyAdmin/compare/v4.7.4...v4.7.5
[4.7.4]: https://github.com/osixia/docker-phpMyAdmin/compare/v4.7.3-1...v4.7.4
[4.7.3-1]: https://github.com/osixia/docker-phpMyAdmin/compare/v4.7.3...v4.7.3-1
[4.7.3]: https://github.com/osixia/docker-phpMyAdmin/compare/v4.7.2...v4.7.3
[4.7.2]: https://github.com/osixia/docker-phpMyAdmin/compare/v4.7.1...v4.7.2
[4.7.1]: https://github.com/osixia/docker-phpMyAdmin/compare/v4.7.0...v4.7.1
[4.7.0]: https://github.com/osixia/docker-phpMyAdmin/compare/v4.6.6...v4.7.0
[4.6.6]: https://github.com/osixia/docker-phpMyAdmin/compare/v4.6.5...v4.6.6
[4.6.5]: https://github.com/osixia/docker-phpMyAdmin/compare/v0.3.7...v4.6.5
[0.3.7]: https://github.com/osixia/docker-phpMyAdmin/compare/v0.3.6...v0.3.7
[0.3.6]: https://github.com/osixia/docker-phpMyAdmin/compare/v0.3.5...v0.3.6
[0.3.5]: https://github.com/osixia/docker-phpMyAdmin/compare/v0.3.4...v0.3.5
[0.3.4]: https://github.com/osixia/docker-phpMyAdmin/compare/v0.3.3...v0.3.4
[0.3.3]: https://github.com/osixia/docker-phpMyAdmin/compare/v0.3.2...v0.3.3
[0.3.2]: https://github.com/osixia/docker-phpMyAdmin/compare/v0.3.1...v0.3.2
[0.3.1]: https://github.com/osixia/docker-phpMyAdmin/compare/v0.3.0...v0.3.1
[0.3.0]: https://github.com/osixia/docker-phpMyAdmin/compare/v0.2.2...v0.3.0
[0.2.2]: https://github.com/osixia/docker-phpMyAdmin/compare/v0.2.1...v0.2.2
[0.2.1]: https://github.com/osixia/docker-phpMyAdmin/compare/v0.2.0...v0.2.1
[0.2.0]: https://github.com/osixia/docker-phpMyAdmin/compare/v0.1.0...v0.2.0
