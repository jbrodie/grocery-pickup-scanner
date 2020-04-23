# Grocery Pickup Scanner

With the current COVID-19 pandemic, everyone should be using the curbside pickup option for your weekly grocery store trip, but there is a problem.  There are only a select few time slots available for pickup times and they fill quickly.  This script is intended to make it easier for you to know when slots are open.

## Getting Started

Follow the setup instructions, and customize for your application.

### Limitations

Currently, the script will work for Real Canadian Superstores and Loblaws as they both use the same website service.

### Installing

Install Ruby 2.7.1 and Bundler

```
rbenv install 2.7.1
gem install bundler -v 2.1.4
bundle install
```

Copy over the sample `.env` and `targets.json` and customize your settings.
```
cp .env.sample .env
cp targets.json.sample targets.json
```

## Authors

* **Jason Brodie** - *Initial work* - [Github](https://github.com/jbrodie)

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details
