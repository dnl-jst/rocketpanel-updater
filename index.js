var async = require('async');
var Docker = require('dockerode');

var docker = new Docker({socketPath: '/var/run/docker.sock'});

var containerConfigurations = [
  {
    ContainerName: 'rocketpanel-mysql',
    ImageName: 'mysql:5.7',
    Volumes: {
      '/var/lib/mysql': {}
    },
    Hostconfig: {
      Binds: ['/opt/rocketpanel/mysql/data/:/var/lib/mysql']
    },
    Env: [
      'MYSQL_ROOT_PASSWORD=rootpass',
      'MYSQL_DATABASE=rocketpanel'
    ]
  },
  {
    ContainerName: 'rocketpanel-control',
    ImageName: 'dnljst/rocketpanel-control',
    Volumes: {
      '/opt/rocketpanel': {},
      '/var/run/docker.sock': {}
    },
    Hostconfig: {
      Binds: [
        '/opt/rocketpanel:/opt/rocketpanel',
        '/var/run/docker.sock:/var/run/docker.sock'
      ],
      Links: [
        'rocketpanel-mysql:mysql'
      ]
    },
    Env: [
      'WEB_DOCUMENT_ROOT=/app/web'
    ],
    ExposedPorts: {
      '8444:443': {}
    }
  }
];

async.mapLimit(
  containerConfigurations,
  3,
  function(containerConfiguration, clb) {

    docker.createContainer({
      name: containerConfiguration.ContainerName,
      Image: containerConfiguration.ImageName,
      Volumes: containerConfiguration.Volumes,
      Hostconfig: containerConfiguration.Hostconfig,
      Env: containerConfiguration.Env,
      ExposedPorts: containerConfiguration.ExposedPorts
    }, function(err, container) {

      if (err) {
        console.log(err);
        return;
      }

      container.start();

    });

  },
  function(err) {
    console.log(err);
  }
);