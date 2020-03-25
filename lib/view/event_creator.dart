import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_luban/flutter_luban.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:intl/intl.dart';
import 'package:mobx/mobx.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sdygd/common/config.dart';
import 'package:sdygd/common/event_creator_manager.dart';
import 'package:sdygd/common/image_pick.dart';
import 'package:sdygd/view/event_creation_progress_page.dart';

part 'event_creator.g.dart';

enum _CreateEventSteps {
    DATE_AND_NAME,
    CAPTIONS,
    IMAGES,
}

class EventCreator extends StatefulWidget {
    @override
    State<StatefulWidget> createState() => _EventCreatorState();
}

class _EventCreatorState extends State<EventCreator> {
    
    _EventCreatorController _controller;
    
    @override
    Widget build(BuildContext context) => new Scaffold(
        body: new NestedScrollView(
            headerSliverBuilder: (_, __) => <Widget>[
                new SliverAppBar(
                    title: new Text(
                        "Buat Acara",
                    ),
                ),
            ],
            body: new Padding(
                padding: const EdgeInsets.symmetric( vertical: 10.0, horizontal: 20.0 ),
                child: new Observer(
                    builder: ( _ ) => new Stepper(
                        type: StepperType.vertical,
                        currentStep: _controller.stepIndex.index,
                        onStepContinue: _controller.onStepNext,
                        onStepCancel: _controller.onStepPrev,
                        onStepTapped: _controller.onStepIndex,
                        steps: <Step>[
                            new Step(
                                isActive: true,
                                state: _controller.dateAndNameStepState,
                                title: const Text("Tanggal dan Nama"),
                                content: new Center(
                                    child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                            new FlatButton(
                                                child: new Observer(
                                                    builder: ( _ ) => new Text(
                                                        new DateFormat("EEEE, dd MMMM yyyy", "id").format( _controller.date ),
                                                        style: const TextStyle(
                                                            fontSize: 20.0,
                                                            fontWeight: FontWeight.w700,
                                                        ),
                                                    ),
                                                ),
                                                onPressed: _controller.pickDate,
                                            ),
                                            new SizedBox( height: 20.0, ),
                                            new TextField(
                                                decoration: new InputDecoration(
                                                    labelText: "Nama",
                                                    errorText: _controller.formErrorState.name,
                                                ),
                                                onChanged: ( final String text ) => _controller.name = text,
                                            ),
                                        ],
                                    ),
                                ),
                            ),
                            new Step(
                                isActive: true,
                                state: _controller.captionState,
                                title: const Text("Caption"),
                                content: new TextField(
                                    decoration: new InputDecoration(
                                        labelText: "Caption",
                                        errorText: _controller.formErrorState.caption,
                                    ),
                                    maxLines: 10,
                                    onChanged: ( final String text ) => _controller.caption = text,
                                )
                            ),
                            new Step(
                                isActive: true,
                                state: _controller.imagesState,
                                title: const Text("Gambar"),
                                content: new Observer(
                                    builder: ( _ ) {
                                        if ( _controller.formErrorState.image != null ) {
                                            return new Text(
                                                _controller.formErrorState.image,
                                                style: new TextStyle(
                                                    color: Theme.of(context).errorColor,
                                                ),
                                            );
                                        } else {
                                            return new ListView.separated(
                                                itemCount: _controller.images.length,
                                                separatorBuilder: ( _, __ ) => new SizedBox( height: 20.0, ),
                                                shrinkWrap: true,
                                                physics: const NeverScrollableScrollPhysics(),
                                                itemBuilder: ( _, final int index ) => new Dismissible(
                                                    key: Key( _controller.images[index].path ),
                                                    onDismissed: ( _ ) => _controller.removePicture( _controller.images[index] ),
                                                    child: new Card(
                                                        elevation: DEFAULT_ELEVATION,
                                                        child: new Image.file(
                                                            _controller.images[index],
                                                            fit: BoxFit.fitWidth,
                                                            height: MediaQuery.of(context).size.width * 0.6,
                                                        ),
                                                    ),
                                                )
                                            );
                                        }
                                    },
                                )
                            ),
                        ],
                    ),
                ),
            ),
        ),
        floatingActionButton: new Observer(
            builder: ( _ ) {
                if ( _controller.stepIndex == _CreateEventSteps.IMAGES ) {
                    return new FloatingActionButton(
                        child: const Icon( Icons.add_a_photo ),
                        onPressed: _controller.addPicture,
                    );
                } else {
                    return new Container();
                }
            },
        ),
    );
    
    @override
    void initState() {
        _controller = new _EventCreatorController( context );
        super.initState();
    }
    
    @override
    void dispose() {
        _controller.dispose();
        super.dispose();
    }
}

class _EventCreatorController = _EventCreatorControllerBase with _$_EventCreatorController;

abstract class _EventCreatorControllerBase with Store {
    final _FormErrorState formErrorState = new _FormErrorState();
    final _reactionDisposer = new List<ReactionDisposer>();
    final BuildContext context;
    @observable String name = "";
    @observable String caption = "";
    @observable List<File> images = new List();
    @observable DateTime date = DateTime.now();
    @observable _CreateEventSteps stepIndex = _CreateEventSteps.DATE_AND_NAME;
    
    List<_CreateEventSteps> _visitedSteps = new List.of( [ _CreateEventSteps.DATE_AND_NAME ] );
    
    _EventCreatorControllerBase(this.context) {
        _reactionDisposer.addAll([
            reaction( ( _ ) => stepIndex, _onStepIndexChange ),
            reaction( ( _ ) => name, _validateName ),
            reaction( ( _ ) => caption, _validateCaption ),
            reaction( ( _ ) => images, _validateImages ),
        ]);
    }
    
    @computed StepState get dateAndNameStepState {
        if ( stepIndex == _CreateEventSteps.DATE_AND_NAME ) return StepState.editing;
        else if ( _visitedSteps.contains( _CreateEventSteps.DATE_AND_NAME ) && stepIndex != _CreateEventSteps.DATE_AND_NAME && name.isNotEmpty ) return StepState.complete;
        else if ( _visitedSteps.contains( _CreateEventSteps.DATE_AND_NAME ) && stepIndex != _CreateEventSteps.DATE_AND_NAME && name.isEmpty ) return StepState.error;
        else return StepState.indexed;
    }

    @computed StepState get captionState {
        if ( stepIndex == _CreateEventSteps.CAPTIONS ) return StepState.editing;
        else if ( _visitedSteps.contains( _CreateEventSteps.CAPTIONS ) && stepIndex != _CreateEventSteps.CAPTIONS && caption.isNotEmpty ) return StepState.complete;
        else if ( _visitedSteps.contains( _CreateEventSteps.CAPTIONS ) && stepIndex != _CreateEventSteps.CAPTIONS && caption.isEmpty ) return StepState.error;
        else return StepState.indexed;
    }

    @computed StepState get imagesState {
        if ( stepIndex == _CreateEventSteps.IMAGES ) return StepState.editing;
        else if ( _visitedSteps.contains( _CreateEventSteps.IMAGES ) && stepIndex != _CreateEventSteps.IMAGES && images.isNotEmpty ) return StepState.complete;
        else if ( _visitedSteps.contains( _CreateEventSteps.IMAGES ) && stepIndex != _CreateEventSteps.IMAGES && images.isEmpty ) return StepState.error;
        else return StepState.indexed;
    }
    
    void _onStepIndexChange( final _CreateEventSteps step ) {
        if ( _visitedSteps.contains( step ) ) return;
        else _visitedSteps.add( step );
    }
    
    @action void _validateName( final String name ) => formErrorState.name = name.isEmpty ? "Nama tidak boleh kosong" : null;
    
    @action void _validateCaption( final String caption ) => formErrorState.caption = caption.isEmpty ? "Caption tidak boleh kosong" : null;
    
    @action void _validateImages( final List<File> images ) => formErrorState.image = images.isEmpty ? "Paling tidak ada satu gambar" : null;
    
    @action void onStepNext() {
        switch ( stepIndex ) {
            case _CreateEventSteps.DATE_AND_NAME: {
                _validateName(name);
                if ( !formErrorState.hasErrors ) save();
                else stepIndex = _CreateEventSteps.CAPTIONS;
            } break;
            
            case _CreateEventSteps.CAPTIONS: {
                _validateCaption(caption);
                if ( !formErrorState.hasErrors ) save();
                else stepIndex = _CreateEventSteps.IMAGES;
            } break;
            
            case _CreateEventSteps.IMAGES: {
                _validateImages(images);
                save();
            } break;
        }
    }
    
    @action void onStepPrev() {
        if ( stepIndex.index > 0 ) stepIndex = _CreateEventSteps.values[ stepIndex.index - 1 ];
    }
    
    @action void onStepIndex( final int index ) => stepIndex = _CreateEventSteps.values[index];
    
    @action Future<void> addPicture() async {
        final image = await ImagePick.pickImage( context, crop: true );
        if ( image == null ) return;
        final compressObject = new CompressObject(
            imageFile: image,
            path: ( await getTemporaryDirectory() ).path,
            quality: 85,
        );
        final path = await Luban.compressImage( compressObject );
        images.add( new File( path ) );
        images = new List.from( images );
    }
    
    @action Future<void> removePicture( final File file ) async {
        images.remove( file );
        images = new List.from( images );
        file.delete();
    }
    
    @action Future<void> pickDate() async {
        final date = await showDatePicker(
            context: context,
            initialDate: this.date,
            firstDate: new DateTime(1970),
            lastDate: new DateTime.now(),
        );
        if ( date != null ) this.date = date;
    }
    
    @action void save() {
        _validateName(name);
        if ( formErrorState.name != null ) {
            stepIndex = _CreateEventSteps.DATE_AND_NAME;
            return;
        }
        _validateCaption(caption);
        if ( formErrorState.caption != null ) {
            stepIndex = _CreateEventSteps.CAPTIONS;
            return;
        }
        _validateImages(images);
        if ( formErrorState.image != null ) {
            stepIndex = _CreateEventSteps.IMAGES;
            return;
        }
        if ( formErrorState.hasErrors ) return;
        EventCreatorManager.instance.create(
            date: date,
            name: name,
            caption: caption,
            images: images,
        );
        Navigator.of(context).pushReplacement(
            new MaterialPageRoute(
                builder: ( _ ) => new EventCreationProgressPage()
            ),
        );
    }
    
    void dispose() {
        for ( final disposer in _reactionDisposer ) disposer();
    }
    
}

class _FormErrorState = _FormErrorStateBase with _$_FormErrorState;

abstract class _FormErrorStateBase with Store {
    @observable String name;
    @observable String caption;
    @observable String image;
    
    @computed
    bool get hasErrors => name != null || caption != null || image != null;
}
