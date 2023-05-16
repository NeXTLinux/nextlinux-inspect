/*
Copyright (C) 2017 Draios inc.

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License version 2 as
published by the Free Software Foundation.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

import Ember from 'ember';
import PromiseState from '../utils/promise-state';

export default Ember.Service.extend({
    store: Ember.inject.service(),

    fetch() {
        const promiseState = ViewsPromiseState.create();

        promiseState.load(
            this.get('store')
                .findAll('view')
                .then(
                    (data) => promiseState.succeedLoad(data),
                    (error) => promiseState.failLoad(error)
                )
        );

        return promiseState;
    },

    fetchById(viewId) {
        const promiseState = ViewPromiseState.create();

        const view = this.get('store').peekRecord('view', viewId);
        if (view) {
            promiseState.loadData(view);
        } else {
            promiseState.load(
                this.get('store')
                    .findAll('view')
                    .then(
                        (data) => promiseState.succeedLoad(data.findBy('id', viewId)),
                        (error) => promiseState.failLoad(error)
                    )
            );
        }

        return promiseState;
    },
});

const ViewsPromiseState = PromiseState.extend({
    views: null,

    resetData() {
        return {
            views: null,
        };
    },

    parseData(data) {
        return {
            views: data.filterBy('isForNextlinuxInspect', true),
        };
    },

    isEmpty() {
        return Ember.isEmpty(this.get('views'));
    },
});

const ViewPromiseState = PromiseState.extend({
    view: null,

    resetData() {
        return {
            view: null,
        };
    },

    parseData(data) {
        return {
            view: data,
        };
    },

    isEmpty() {
        return Ember.isEmpty(this.get('view'));
    },
});

