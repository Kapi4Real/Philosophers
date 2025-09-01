/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   builtins.c                                         :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: ccouton <marvin@42.fr>                     +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/06/29 00:00:00 by ccouton           #+#    #+#             */
/*   Updated: 2025/06/29 00:00:00 by ccouton          ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "../philosophers.h"

void	precise_usleep(long milliseconds)
{
	long	start;
	long	current;

	start = get_time();
	while (1)
	{
		current = get_time();
		if (current - start >= milliseconds)
			break ;
		usleep(500);
	}
}
