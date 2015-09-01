# <a name="title"></a> Kitchen::Scaleway

A Test Kitchen Driver for Scaleway.

## <a name="requirements"></a> Requirements

This driver depends on the Scaleway gem. Additionally, you will need to
create an account on Scaleway https://www.scaleway.com.

Currently, there is no omnibus package for Test Kitchen to use via this driver.
However, as this driver exists I aim to publish some soon.

## <a name="installation"></a> Installation and Setup

Please read the [Driver usage][driver_usage] page for more details.

## <a name="config"></a> Configuration

There are two required options which can either be set as system environment
variables or as driver options.

Environment Variables:
```bash
export SCALEWAY_ORG_TOKEN='66c8226d-4b6d-455a-a40a-507faa3fac2b'
export SCALEWAY_ACCESS_TOKEN='1800d055-03ef-4109-9ad9-0d3c2cb2004a'
```

kitchen.local.yml options:
```yaml
driver:
  name: scaleway
  scaleway_org: 66c8226d-4b6d-455a-a40a-507faa3fac2b
  scaleway_access_token: 1800d055-03ef-4109-9ad9-0d3c2cb2004a
```

### <a name="config-require-chef-omnibus"></a> require\_chef\_omnibus

Determines whether or not a Chef [Omnibus package][chef_omnibus_dl] will be
installed. There are several different behaviors available:

* `true` - the latest release will be installed. Subsequent converges
  will skip re-installing if chef is present.
* `latest` - the latest release will be installed. Subsequent converges
  will always re-install even if chef is present.
* `<VERSION_STRING>` (ex: `10.24.0`) - the desired version string will
  be passed the the install.sh script. Subsequent converges will skip if
  the installed version and the desired version match.
* `false` or `nil` - no chef is installed.

The default value is unset, or `nil`.

## <a name="development"></a> Development

* Source hosted at [GitHub][repo]
* Report issues/questions/feature requests on [GitHub Issues][issues]

Pull requests are very welcome! Make sure your patches are well tested.
Ideally create a topic branch for every separate change you make. For
example:

1. Fork the repo
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## <a name="authors"></a> Authors

Created and maintained by [Ryan Hass][author] (<ryan@invalidchecksum.net>)

Much of this code was derived and borrowed from
[kitchen-digitalocean](https://github.com/test-kitchen/kitchen-digitalocean).

Special thanks to [Greg Fitzgerald](https://github.com/gregf/) (<greg@gregf.org>)

## <a name="license"></a> License

Apache 2.0 (see [LICENSE][license])


[author]:           https://github.com/rhass
[issues]:           https://github.com/rhass/kitchen-scaleway/issues
[license]:          https://github.com/rhass/kitchen-scaleway/blob/master/LICENSE
[repo]:             https://github.com/rhass/kitchen-scaleway
[driver_usage]:     http://docs.kitchen-ci.org/drivers/usage
[chef_omnibus_dl]:  https://www.chef.io/chef/get-chef/
