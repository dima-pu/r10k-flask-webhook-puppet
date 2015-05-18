class r10kflaskhook {

    vcsrepo { "/var/www/github-webhook-handler":
      ensure   => latest,
      provider => git,
      source   => "https://github.com/razius/github-webhook-handler.git",
      revision => 'master'
    }
}
