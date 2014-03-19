<div id="backend" class="modal fade" tabindex="-1" role="dialog" aria-labelledby="backendModalLabel" aria-hidden="true">
  <div id="backend-modal" class="modal-dialog">
    <div class="modal-content">
      <div class="modal-body">

        <!-- Nav tabs -->
        <ul class="nav nav-tabs">
          <li class="active"><a href="#backend-hivents" data-toggle="tab">Hivents</a></li>
          <li><a href="#backend-multimedia" data-toggle="tab">Multimedia</a></li>
          <li><a href="#backend-borders" data-toggle="tab">Grenzen</a></li>
        </ul>

        <p></p>

        <!-- Tab panes -->
        <div class="tab-content">
          <div class="tab-pane fade in active" id="backend-hivents">

            <div class="row">
              <div class="col-md-4">

                <!-- Hivent list -->
                <nav class="navbar navbar-default stringlist-header" role="navigation">
                  <form class="navbar-form navbar-left" role="search">
                    <div class="input-group">
                      <span class="input-group-addon"><i class="fa fa-search"></i></span>
                      <input type="text" class="form-control" placeholder="Filtern...">
                    </div>
                  </form>
                </nav>

                <div class="list-group stringlist-content">
                  <a href="#" class="list-group-item">
                    <p class="list-group-item-text"><span class="text-muted">10.12.1234 | </span> Dapibus ac facilisis in</p>
                  </a>
                  <a href="#" class="list-group-item">
                    <p class="list-group-item-text"><span class="text-muted">10.12.1234 | </span> Dapibus ac facilisis in</p>
                  </a>
                  <a href="#" class="list-group-item">
                    <p class="list-group-item-text"><span class="text-muted">10.12.1234 | </span> Dapibus ac facilisis in</p>
                  </a>
                  <a href="#" class="list-group-item">
                    <p class="list-group-item-text"><span class="text-muted">10.12.1234 | </span> Dapibus ac facilisis in</p>
                  </a>
                  <a href="#" class="list-group-item">
                    <p class="list-group-item-text"><span class="text-muted">10.12.1234 | </span> Dapibus ac facilisis in</p>
                  </a>
                  <a href="#" class="list-group-item active">
                    <p class="list-group-item-text"><span class="text-muted">10.12.1234 | </span> Dapibus ac facilisis in</p>
                  </a>
                  <a href="#" class="list-group-item">
                    <p class="list-group-item-text"><span class="text-muted">10.12.1234 | </span> Morbi leo risus</p>
                  </a>
                  <a href="#" class="list-group-item">
                    <p class="list-group-item-text"><span class="text-muted">10.12.1234 | </span> Morbi leo risus</p>
                  </a>
                  <a href="#" class="list-group-item">
                    <p class="list-group-item-text"><span class="text-muted">10.12.1234 | </span> Porta ac consectetur ac</p>
                  </a>
                  <a href="#" class="list-group-item">
                    <p class="list-group-item-text"><span class="text-muted">10.12.1234 | </span> Porta ac consectetur ac</p>
                  </a>
                  <a href="#" class="list-group-item">
                    <p class="list-group-item-text"><span class="text-muted">10.12.1234 | </span> Vestibulum at eros</p>
                  </a>
                  <a href="#" class="list-group-item">
                    <p class="list-group-item-text"><span class="text-muted">10.12.1234 | </span> Vestibulum at eros</p>
                  </a>
                </div>

                <nav class="navbar navbar-default stringlist-footer">
                  <form class="navbar-form navbar-right">
                    <div class="btn-group">
                      <button type="button" class="btn btn-default hg-tooltip"
                              data-toggle="tooltip" data-placement="bottom"
                              title="Erstellt ein neues Hivent">
                        <i class="fa fa-plus"></i>
                      </button>
                      <button type="button" class="btn btn-default hg-tooltip"
                              data-toggle="tooltip" data-placement="bottom"
                              title="Löscht das gewählte Hivent">
                        <i class="fa fa-minus"></i>
                      </button>
                    </div>
                  </form>
                </nav>


              </div>
              <div class="col-md-8">

                <!-- Edit area -->
                <form class="form-horizontal" role="form">

                  <!-- Name -->
                  <div class="form-group">
                    <label for="backendInputName" class="col-md-4 control-label">Name</label>
                    <div class="col-md-8">
                      <input id="backendInputName" class="form-control" placeholder="Name">
                    </div>
                  </div>

                  <!-- Coords -->
                  <div class="form-group">
                    <label for="backendInputCoords" class="col-md-4 control-label">Koordinaten</label>
                    <div class="col-md-8">
                      <div class="row">
                        <div class="col-xs-6">
                          <input id="backendInputCoords" class="form-control" placeholder="Breite">
                        </div>
                        <div class="col-xs-6">
                          <input class="form-control" placeholder="Länge">
                        </div>
                      </div>
                    </div>
                  </div>

                  <!-- Date -->
                  <div class="form-group">
                    <label for="backendInputDate" class="col-md-4 control-label">Datum</label>
                    <div class="col-md-8">
                      <div class="row">
                        <div class="col-xs-6">
                          <input id="backendInputDate" class="form-control" placeholder="Beginn">
                        </div>
                        <div class="col-xs-6">
                          <input class="form-control" placeholder="Ende">
                        </div>
                      </div>
                    </div>
                  </div>

                  <!-- Text -->
                  <div class="form-group">
                    <label for="backendInputText" class="col-md-4 control-label">Beschreibung</label>
                    <div class="col-md-8">
                      <textarea id="backendInputText" class="form-control" rows="3"></textarea>
                    </div>
                  </div>
                </form>

              </div>
            </div>
          </div>



          <div class="tab-pane fade in" id="backend-multimedia">
            ...
          </div>


          <div class="tab-pane fade in" id="backend-borders">
            ...
          </div>

        </div>
      </div>
      <div class="modal-footer">
        <button type="button" data-dismiss="modal" class="btn btn-default" data-dismiss="modal">Abbrechen</button>
        <button type="button" class="btn btn-primary">Speichern</button>
      </div>
    </div>
  </div>
</div>
