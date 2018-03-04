var IPFS = require('ipfs');
var Y = require('yjs');

require('y-memory')(Y);
require('y-array')(Y);
require('y-text')(Y);
require('y-ipfs-connector')(Y);

exports.getIpfs = function (repo) {
  return new IPFS({
    repo: repo,
    EXPERIMENTAL: {
      pubsub: true
    }
  });
};

exports.ipfsOnceReadyImpl = function(right) {
  return function(ipfs) {
    return function(cb) {
      return function() {
        ipfs.once('ready', function() {
          cb(right({}));
        });

        return function() {};
      };
    };
  };
};

exports.doTheThing = function (ipfs) {
  ipfs.once('ready', function () {
    return ipfs.id(function (err, info) {
      if (err) { throw err; }

      console.log('IPFS node ready with address ' + info.id);

      Y({
        db: {
          name: 'memory'
        },
        connector: {
          name: 'ipfs',
          room: 'hardy-and-harding',
          ipfs: ipfs
        },
        share: {
          textfield: 'Text'
        }
      }).then(function (y) {
        y.share.textfield.bind(
          document.getElementById('textfield')
        );
      });
    });
  });
};
