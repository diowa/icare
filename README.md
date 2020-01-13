# icare
[![Build Status](https://secure.travis-ci.org/diowa/icare.svg?branch=master)](https://travis-ci.org/diowa/icare) [![Maintainability](https://api.codeclimate.com/v1/badges/b5c7bd31597d298a5d6e/maintainability)](https://codeclimate.com/github/diowa/icare/maintainability) [![Coverage Status](https://coveralls.io/repos/diowa/icare/badge.svg?branch=master)](https://coveralls.io/r/diowa/icare?branch=master) [![Dependabot Status](https://api.dependabot.com/badges/status?host=github&repo=diowa/icare)](https://dependabot.com)

[![Gitter](https://badges.gitter.im/diowa/icare.svg)](https://gitter.im/diowa/icare?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge)

[![Deploy](https://www.herokucdn.com/deploy/button.svg)](https://heroku.com/deploy)

**icare** is an open source [carpooling](https://en.wikipedia.org/wiki/Carpool) platform used as a basis for our commercial product [Company Carpool](https://www.companycarpool.com).

Carpooling (also known as car-sharing, ride-sharing, lift-sharing and covoiturage), is the sharing of car journeys so that more than one person travels in a car.
By having more people using one vehicle, carpooling reduces each person’s travel costs such as fuel costs, tolls, and the stress of driving. Carpooling is also seen as a more environmentally friendly and sustainable way to travel as sharing journeys reduces carbon emissions, traffic congestion on the roads, and the need for parking spaces. Authorities often encourage carpooling, especially during high pollution periods and high fuel prices. (From Wikipedia)

**icare** uses the following technologies:

* [Ruby on Rails][1]
* [Webpacker][3]
* [Handlebars.js][4] (JavaScript semantic templates)
* [SLIM][5]
* [Bootstrap][6]
* [Font Awesome][7] (vectorial icons)
* [Devise][2]
* Asynchronous tasks with [Sucker Punch][9]
* Facebook Open Graph / Rest API with [Koala][11]
* Google Maps API
* [RSpec][12]
* [Heroku][14] Cloud Application Platform
* [Multi-Environment configuration][15]
* [Airbrake][16] Exception Notification
* [New Relic][13] Application Performance Management service

 [1]: https://rubyonrails.org/
 [2]: https://github.com/plataformatec/devise
 [3]: https://github.com/rails/webpacker
 [4]: https://handlebarsjs.com/
 [5]: http://slim-lang.com/
 [6]: https://getbootstrap.com
 [7]: https://fontawesome.com
 [9]: https://github.com/brandonhilkert/sucker_punch
 [11]: https://github.com/arsduo/koala
 [12]: https://rspec.info/
 [13]: https://newrelic.com/
 [14]: https://www.heroku.com/
 [15]: https://github.com/lukeredpath/simpleconfig
 [16]: https://github.com/airbrake/airbrake

A working demo is available at https://icare.diowa.com/



## Name and logo

**icare** name and logo are temporary. **icare** is a portmanteau of "I care", "Car" and "Environment". No copyright violation is intended.



## Roadmap

Immediate: Check out our [To Do](https://github.com/diowa/icare/wiki/To-Do) list.
Long-term: TODO



## Internationalization (i18n)

**icare** uses standard [Rails Internationalization (I18n) API](https://guides.rubyonrails.org/i18n.html). If you translated **icare** in your own language, make a pull request.



## Contributing

Please read through our [contributing guidelines](CONTRIBUTING.md). Included are directions for opening issues, coding standards, and notes on development.

More over, if your pull request contains patches or features, you must include relevant unit tests.

Editor preferences are available in the [editor config](.editorconfig) for easy use in common text editors. Read more and download plugins at <https://editorconfig.org>.

If you are interested in feature development, we have priorities. Check out our [To Do](https://github.com/diowa/icare/wiki/To-Do) list.



## Authors

**Geremia Taglialatela**

+ https://github.com/tagliala
+ https://twitter.com/gtagliala

**Cesidio Di Landa**

+ https://github.com/cesidio
+ https://twitter.com/cesid



## Copyright and license

**icare** is licensed under the BSD 2-Clause License

Check the LICENSE file for more information



## Thanks

Special thanks to all developers of open source libraries used in this project.



## Docker (Experimental)

Experimental Docker support. Please do not ask for support, PR to improve the
current implementation are very welcomed.

TODO:
- [ ] Fix Puma exit status (puma/puma#1673)
- [ ] Check multi-environment support
- [ ] Add Sidekiq container

Generate SSL requirements:

```ssh
openssl req -subj '/CN=localhost' -x509 -newkey rsa:4096 -nodes -keyout docker/nginx/ssl/app_key.pem -out docker/nginx/ssl/app_cert.pem -days 825
openssl genpkey -genparam -algorithm DH -out docker/nginx/ssl/app_dhparam4096.pem -pkeyopt dh_paramgen_prime_len:4096
```

Copy `docker/icare/variables.env.example` to `docker/icare/variables.env` and
run `docker-compose up`

icare will be accessible on `https://localhost:3443`

### Start rails outside of Docker with SSL

After generating the SSL requirements, run:

```sh
rails s -b 'ssl://0.0.0.0:3443?key=docker/nginx/ssl/app_key.pem&cert=docker/nginx/ssl/app_cert.pem'
```

icare will be accessible on `https://localhost:3443`

## Donations

If you like this project or you are considering to use it (or any part of it) for commercial purposes, please make a donation to the authors.

[![Donate once-off to this project using Bitcoin](https://img.shields.io/badge/bitcoin-donate-blue.svg)](bitcoin:1L6sqoG8xXhYziH9NGjPzgR1dEP2SbJrfM)
